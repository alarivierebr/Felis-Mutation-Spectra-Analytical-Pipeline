

#----- Heatmap -------#
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np


# #load mutation spectrum
# mutation = pd.read_csv("/mnt/data/project0076/annalise/filtering/mutyper/spectra/nO_felidae_mut.NKnorm.deseq2.csv")
# metadata = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/mutation_calc/metadata_rplots_grouped.csv")

# mutation_types = [
#     col for col in mutation.columns
#     if ">" in col
# ]

# print("Number of mutation types:", len(mutation_types))

# mutation = mutation.merge(
#     metadata[["sample", "Breed", "Group"]],
#     on="sample",
#     how="left"
# )

# print("Samples missing metadata:",
#       mutation["Breed"].isna().sum()
# )

# mutation = mutation.sort_values(
#     ["Breed", "Group", "sample"],
#     na_position="last"
# ).reset_index(drop=True)


# #create matrix for mutation spectruma
# spectrum = mutation.set_index("sample")[mutation_types]

# #ensuring numeric
# spectrum = spectrum.apply(
#     pd.to_numeric,
#     errors="coerce"
# )


# breed_spectrum = (
#     mutation.groupby("Breed")[mutation_types].mean()
# )
# breed_spectrum = breed_spectrum.sort_index()


# print("Number of mutation types", len(mutation_types))
# print(mutation_types)
# print("Spectrum shape:", spectrum.shape)
# print(spectrum.iloc[:5,:5])


# spectrum_z =(
#     breed_spectrum - breed_spectrum.mean(axis=0)
# ) / breed_spectrum.std(axis=0)


# plt.figure(figsize = (18, 10))

# sns.set_theme(
#     style="white",
#     context="paper",
#     font_scale=1.2
# )

# fig, ax = plt.subplots(
#     figsize=(18, 12)
# )

# sns.heatmap(
#     spectrum_z,
#     cmap="RdBu_r",
#     center=0,
#     xticklabels=True,
#     yticklabels=True,
#     linewidths=0,
#     cbar_kws={
#         "label": "Standardized mutation rate"
#     },
#     ax=ax
# )

# breed_counts = mutation["Breed"].value_counts(
#     sort=False
# )

# breed_sizes = (
#     mutation.groupby("Breed", sort=False)
#     .size()
# )

# cumulative =breed_sizes.cumsum()

# for position in cumulative.iloc[:-1]:
#     ax.axhline(
#         position,
#         color= "black",
#         linewidth=1.2
#     )



# plt.xlabel("Mutation type", fontsize=13)
# plt.ylabel("Sample", fontsize=13)
# plt.title("Mutation spectra", fontsize=16, weight="bold")

# plt.xticks(rotation=90, fontsize=7)

# plt.yticks(fontsize=7)

# plt.tight_layout()

# plt.savefig(
#     "mutation_spectrum_heatmap.png",
#     dpi=600,
#     bbox_inches="tight"
# )

# plt.show()


#----------- PCA -------------------#
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

#load mutation spectru

pca = pd.read_csv("/mnt/data/project0076/annalise/filtering/mutyper/spectra/nO_felidae_mut.NKnorm.deseq2.csv")
metadata = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/mutation_calc/metadata_rplots_grouped.csv")



# #loading metadata, includes information on Breed and Group
# metadata = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/plink_files_pca/metadata2.csv")

#merge metadata and pca coordinates into one data frame
pca=pca.merge(metadata, on="sample", how="left")

sns.set_theme(style="white", context="paper", font_scale=1.3)

plt.figure(figsize=(8, 7))

groups = pca["Breed"].unique()

palette = sns.color_palette("hls", len(groups))

sns.scatterplot(
    data=pca,
    x="PC1",
    y="PC2",
    hue="Group",
    palette=palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )

# plt.xlabel(
#     f"PC1 ({pc1_variance:.2f}%)", fontsize=14)
# plt.ylabel(
#     f"PC2 ({pc2_variance:.2f}%)", fontsize=14)
plt.xlabel("PC1")
plt.ylabel("PC2")
plt.title("Variants PCA", fontsize=16, weight="bold")

plt.legend(
    title= "Group",
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True,
    fontsize=9,
    title_fontsize=10,
)

sns.despine()
plt.tight_layout()
plt.savefig("pca_test.png", dpi=600, bbox_inches="tight")