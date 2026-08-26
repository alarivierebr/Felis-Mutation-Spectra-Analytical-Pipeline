import sys
import argparse
import pysam
import logging
import statistics
from dataclasses import dataclass
from typing import List, Optional
#---------------#

'''
Setting up Argument Parsing from Command Line
''' 
parser = argparse.ArgumentParser(description = "Annotates VCFs with QC statistics useful for filtering")
parser.add_argument("-i", "--input", required=True, help="VCF/BCF in (ex: filename.vcf.gz)")
parser.add_argument("-o", "--output", required=True, help="Name of output vcf file (ex: annotated.vcf)")

args = parser.parse_args()
'''
Accessing the VCF file specified via command line argument, copying the header, checking for AB field and adding if missing
'''

vcf_in = pysam.VariantFile(args.input)
newheader = vcf_in.header.copy()
if newheader.formats.get("AB") is None:
    newheader.formats.add("AB", 1, "Float", "Ratio of sequencing reads for one allele compared to the total reads at a specific site")
vcf_out = pysam.VariantFile(args.output, "wz", header=newheader) #specifying the out file, including the header 


# print(vcf_in.header)
# exit()
'''
Setting up bounds for filtering based on Allele Balance, Mean Depth, Mean Genotype Quality, and Callrate
'''
AB_LOW_BOUND_HET = 0.2
AB_HIGH_BOUND_HET = 0.8

AB_HIGH_BOUND_HOMO = 0.02

DEPTH_LOW_BOUND = 6 
GENOTYPE_QUAL_LOW_BOUND = 20
CALLRATE_LOW_BOUND = 0.9


'''
Setting up constants for filtering specifications Pedersen et al., 2021 and Lazzari et al., 2025

High genotype quality for all samples in a family
GQ ≥ 20 

Allele balance between 0.2 and 0.8 for heterozygous samples
0.2 ≤ AB ≤ 0.8

Allele balance <0.02 homozygous samples
AB < 0.02

Depth of at least 10 for all samples in a family in whole-genome data
DP ≥ 6 (whole-genome only) from Lazzari et al



'''
#Counters to see how many records are being filtered out
qual_counter = 0
alt_counter = 0 #biallelic counter
sample_fail_counter = 0
depth_counter = 0
callrate_counter = 0
genotype_qual_counter = 0
het_allele_bal_counter = 0
homo_allele_bal_counter = 0

'''
Defining some functions
'''

# ------------------
#If the length of the Alts string found in a record is 1, return True, if its longer than 1, returns False
def biallelic_check(record: pysam.VariantRecord) -> bool:

    return record.alts is None or len(record.alts) == 1
#---------------------------

#check for SNP records
def allele_variant_type_check(record: pysam.VariantRecord) -> bool:

    return len(record.alleles_variant_types) < 2 or record.alleles_variant_types[1] == "SNP"


#gets genotype, if missing, returns None. If heterozygous, returns True, otherwise return False (homozygous)
def zygosity_check(sample: pysam.VariantRecordSample) -> Optional[bool]:
    genotype = sample.get("GT")
    if genotype is None or len(genotype) < 2:
        return None
    if genotype[0] is None or genotype[1] is None:
        return None
    return genotype[0] != genotype[1]

#Gets allele depth (number of reads for both the ref and alt alleles in a sample) computes allele balance: ALT / (REF + ALT)
def allele_balance_calc(sample: pysam.VariantRecordSample) -> Optional[float]:
    allele_depth = sample.get("AD")
    if allele_depth is None or len(allele_depth) < 2:
        return None
    ref_depth = allele_depth[0]
    alt_depth = allele_depth[1]


    if ref_depth is None or alt_depth is None:
        return None
    total_depth = ref_depth + alt_depth  #calculating total depth
    if total_depth == 0:
        return None
    return alt_depth / total_depth


#Returns false if heterozygote allele balance is outside of 0.2 - 0.8 range, and anything less than 0.02 for homozygotes 
def ab_filter(allele_balance: float, is_hetero: bool) -> bool:
    if is_hetero:
        return AB_LOW_BOUND_HET <= allele_balance <= AB_HIGH_BOUND_HET  #if heterozygous, check if between 0.2 and 0.8
    return allele_balance < AB_HIGH_BOUND_HOMO



#testing a smaller subset of the samples for proof of concept earlier in making this script
# vcf_in.subset_samples([
#     "SAMN14425427",
#     "SAMN14425428",
#     "SAMN14425429"
# ])


#want to count how many pass and how many fail an individual threshold check for each variant for each sample, then determine the fraction of how many pass out of the total tested varaints for each sample, then if the fraction is high enough -> pass, if not throw the whole variant away for all samples
'''
The SampleStats dataclass stores depths, genotype quality, heterozygous AB, and homozygous AB for samples processed
'''
@dataclass
class SampleStats:
    depths: List[int]
    genotype_qualities: List[int]
    het_allele_balances: List[float]
    homo_allele_balances: List[float]
    missing_genotype_counter: int = 0
    total_depth_missing: int = 0
    genotype_qual_missing: int = 0
    allele_depth_missing: int = 0
    pass_all_count: int = 0
    fail_count: int = 0

    '''
    The process sample function has multiple operations, it checks samples for:

    missing genotype records
    missing depth records
    missing genotype quality records
    missing allele depth records

    and adds +1 to the appropriate counters, for each missing record found
    ensures that only valid samples without missing data are included in later calculations
    '''

    def process_sample(self, sample: pysam.VariantRecordSample) -> Optional[float]:

        is_hetero = zygosity_check(sample)
        if is_hetero is None:
            self.missing_genotype_counter += 1
            self.fail_count += 1
            return None

        total_depth = sample.get("DP")
        if total_depth is None:
            self.total_depth_missing += 1
            self.fail_count += 1
            return None
        if total_depth <= DEPTH_LOW_BOUND:
            self.fail_count += 1
            return None

        genotype_quality = sample.get("GQ")
        if genotype_quality is None:
            self.genotype_qual_missing += 1
            self.fail_count += 1
            return None
        if genotype_quality <= GENOTYPE_QUAL_LOW_BOUND:
            self.fail_count += 1
            return None

        allele_balance = allele_balance_calc(sample)
        if allele_balance is None:
            self.allele_depth_missing += 1
            self.fail_count += 1
            return None

        if is_hetero:
            self.het_allele_balances.append(allele_balance)
        else:
            self.homo_allele_balances.append(allele_balance)

        self.depths.append(total_depth)
        self.genotype_qualities.append(genotype_quality)
        self.pass_all_count += 1

        return round(allele_balance, 3)
    '''
    Calculates mean depth, mean genotype quality, mean heterozygous AB, mean homozygous AB, and callrate for a SampleStats object.
    If no values present in the SampleStats object for depths, genotype_qualities, het_allele_balances, and homo_allele_balances, does not include that particular empty value in the mean calculations
    '''
    def mean_depth(self) -> Optional[float]:
        if len(self.depths) < 1:
            return None
        return statistics.mean(self.depths)
    
    def mean_genotype_qual(self) -> Optional[float]:
        if len(self.genotype_qualities) < 1:
            return None
        return statistics.mean(self.genotype_qualities)

    def mean_het_allele_balance(self) -> Optional[float]:
        if len(self.het_allele_balances) < 1:
            return None
        return statistics.mean(self.het_allele_balances)

    def mean_homo_allele_balance(self) -> Optional[float]:
        if len(self.homo_allele_balances) < 1:
            return None
        return statistics.mean(self.homo_allele_balances)

    def callrate(self) -> Optional[float]:
        if len(self.depths) < 1:
            return None
        return len(self.depths) / (len(self.depths) + self.missing_genotype_counter)


'''
Filtering
'''

record_counter = 0

for record in vcf_in:

    record_counter += 1

    # if record_counter > 10000:
    #     break
    #Reject multiallelic records
    # if not biallelic_check(record):
    #     alt_counter += 1
    #     continue

    #if the record is not a SNP, add to counter and disregard
    if not allele_variant_type_check(record):
        alt_counter += 1
        continue

    
    #Store QC stats
    sample_stats = SampleStats([], [], [], [])

    #Store Allele balance per sample
    ab_values = {}

    #Process each sample once
    for sample_name, sample in record.samples.items():
        allele_balance = sample_stats.process_sample(sample)
        if allele_balance is not None:
            ab_values[sample_name] = allele_balance
    
            
    if sample_stats.pass_all_count / (sample_stats.pass_all_count + sample_stats.fail_count) < 0.9:  #if less than 90% of samples pass all of the filters, continue
        sample_fail_counter += 1
        continue
    #Apply filtering
    # mean_depth = sample_stats.mean_depth()
    # if mean_depth is None or mean_depth <= DEPTH_LOW_BOUND:
    #     depth_counter += 1
    #     continue

    callrate = sample_stats.callrate()
    if callrate is None or callrate <= CALLRATE_LOW_BOUND:
        callrate_counter += 1
        continue

    # mean_genotype_quality = sample_stats.mean_genotype_qual()
    # if mean_genotype_quality is None or mean_genotype_quality <= GENOTYPE_QUAL_LOW_BOUND:
    #     genotype_qual_counter += 1
    #     continue

    het_allele_bal = sample_stats.mean_het_allele_balance()
    if het_allele_bal is None or not ab_filter(het_allele_bal, True):
        het_allele_bal_counter += 1
        continue

    homo_allele_bal = sample_stats.mean_homo_allele_balance()
    if homo_allele_bal is None or not ab_filter(homo_allele_bal, False):
        homo_allele_bal_counter += 1
        continue

    #Create output record using the new header containing AB
    out_record = record.copy()
    out_record.translate(vcf_out.header)


    # Copy sample FORMAT fields and add AB
    for sample_name in out_record.samples:

        if sample_name in ab_values:
            out_record.samples[sample_name]["AB"] = ab_values[sample_name]

    vcf_out.write(out_record)


vcf_out.close()

#print summary, #TODO clean this up to be more readable in the output for final
print(f"Quality count {qual_counter}, genotype count {genotype_qual_counter}, depth count {depth_counter}, callrate {callrate_counter}, alt count {alt_counter}, sample fail counter {sample_fail_counter}")
