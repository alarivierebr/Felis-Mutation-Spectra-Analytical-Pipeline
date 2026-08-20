import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import colorcet as cc
from matplotlib.patches import Ellipse


#------------- Loading Files------------------#

# --------------------- Full cohort-----------------#
#-------------Read eigenvectors (PCA coordinates) ---------------#
FULL_COHORT = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_1/before_filter_pca.eigenvec", sep=r"\s+")
FULL_EIGENVAL = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_1/before_filter_pca.eigenval", header=None)
#loading metadata, includes information on Breed and Group
FULL_metadata = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/plink_files_pca/metadata2.csv")
#---------------- Domestic Only Cohort ---------------------#
DOM_COHORT = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/test4_norm/test4_bcftools_filter/final/dom/dom_only_final.eigenvec", sep=r"\s+")
DOM_EIGENVAL = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/test4_norm/test4_bcftools_filter/final/dom/dom_only_final.eigenval", header=None)
DOM_metadata = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/plink_files_pca/metadata_domestic_grouped.csv")


#-----------------Wild Only Cohort ---------------------#

WILD_COHORT = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/test4_norm/test4_bcftools_filter/final/wild/wild_only_final.eigenvec", sep=r"\s+", header=0)
WILD_EIGEN = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/test4_norm/test4_bcftools_filter/final/wild/wild_only_final.eigenval", header=None)
WILD_metadata = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/plink_files_pca/metadata_wild.csv")
#-----------------PROCESSING PCAS --------------------#


# ----- Full Cohort PCA --------#
variance_explained = FULL_EIGENVAL[0] / FULL_EIGENVAL[0].sum() * 100

pc1_variance = variance_explained.iloc[0]
pc2_variance = variance_explained.iloc[1]

#merge metadata and pca coordinates into one data frame
FULL_COHORT=FULL_COHORT.merge(FULL_metadata, on="IID", how="left")

sns.set_theme(style="white", context="paper", font_scale=1.3)

plt.figure(figsize=(8, 7))

groups = FULL_COHORT["Group"].unique()

palette = sns.color_palette("hls", len(groups))

sns.scatterplot(
    data=FULL_COHORT,
    x="PC1",
    y="PC2",
    hue="Group",
    palette=palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )

plt.xlabel(
    f"PC1 ({pc1_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC2 ({pc2_variance:.2f}%)", fontsize=14)
plt.title("Full Cohort - Pre Filter", fontsize=16, weight="bold")

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
plt.savefig("Full Cohort PCA_1_2", dpi=600, bbox_inches="tight")

#--------- PC3 and 4 -------------------#

pc3_variance = variance_explained.iloc[2]
pc4_variance = variance_explained.iloc[3]

sns.scatterplot(
    data=FULL_COHORT,
    x="PC3",
    y="PC4",
    hue="Group",
    palette=palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )

plt.xlabel(
    f"PC3 ({pc3_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC4 ({pc4_variance:.2f}%)", fontsize=14)
plt.title("Full Cohort - Pre Filter", fontsize=16, weight="bold")

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
plt.savefig("Full Cohort PCA_3_4", dpi=600, bbox_inches="tight")

#--------------------Domestic Only Set-------------------#


# variance calcs
variance_explained = DOM_EIGENVAL[0] / DOM_EIGENVAL[0].sum() * 100

pc1_variance = variance_explained.iloc[0]
pc2_variance = variance_explained.iloc[1]

#loading metadata, includes information on Breed and Group


DOM_COHORT.columns = [
    "FID", "IID",
    "PC1", "PC2", "PC3", "PC4", "PC5",
    "PC6", "PC7", "PC8", "PC9", "PC10"
]

#merge metadata and pca coordinates into one data frame
DOM_COHORT=DOM_COHORT.merge(DOM_metadata, on="IID", how="left")

sns.set_theme(style="white", context="paper", font_scale=1.3)

plt.figure(figsize=(10, 8))

breeds = DOM_COHORT["Breed"].unique()

palette = cc.glasbey_bw_minc_20_maxl_70[:DOM_COHORT["Breed"].nunique()]
breed_palette = dict(zip(breeds, palette))

sns.scatterplot(
    data=DOM_COHORT,
    x="PC1",
    y="PC2",
    hue="Breed",
    palette=breed_palette,
    s=30,
    alpha=0.8,
    linewidth=0.5,
    edgecolor="black"
    )


plt.xlabel(
    f"PC1 ({pc1_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC2 ({pc2_variance:.2f}%)", fontsize=14)
plt.title("Domestic Cohort PCA, maf = 0.05, genotype = 0.1", fontsize=16, weight="bold")


handles, labels = plt.gca().get_legend_handles_labels()
order = sorted(zip(labels, handles), key = lambda x: x[0])

plt.legend(
    [h for l, h in order],
    [l for l, h in order],
    title= "Breed",
    bbox_to_anchor=(0.5, -0.15),
    loc="upper center",
    ncol=6,
    frameon=True,
    fontsize=8,
    title_fontsize=10,
)

sns.despine()
plt.tight_layout()
plt.subplots_adjust(bottom=0.25)
plt.savefig("Dom_Only_PCA_1_2.png", dpi=600, bbox_inches="tight")


#--------------------Domestic Only Set PC3 and 4-------------------#
pc3_variance = variance_explained.iloc[2]
pc4_variance = variance_explained.iloc[3]

sns.scatterplot(
    data=DOM_COHORT,
    x="PC3",
    y="PC4",
    hue="Breed",
    palette=breed_palette,
    s=30,
    alpha=0.8,
    linewidth=0.5,
    edgecolor="black"
    )


plt.xlabel(
    f"PC3 ({pc3_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC4 ({pc4_variance:.2f}%)", fontsize=14)
plt.title("Domestic Cohort PCA, maf = 0.05, genotype = 0.1", fontsize=16, weight="bold")


handles, labels = plt.gca().get_legend_handles_labels()
order = sorted(zip(labels, handles), key = lambda x: x[0])

plt.legend(
    [h for l, h in order],
    [l for l, h in order],
    title= "Breed",
    bbox_to_anchor=(0.5, -0.15),
    loc="upper center",
    ncol=6,
    frameon=True,
    fontsize=8,
    title_fontsize=10,
)

sns.despine()
plt.tight_layout()
plt.subplots_adjust(bottom=0.25)
plt.savefig("Dom_Only_PCA_3_4.png", dpi=600, bbox_inches="tight")

#--------------------Wild Only Set-------------------#

variance_explained = WILD_EIGEN[0] / WILD_EIGEN[0].sum() * 100

pc1_variance = variance_explained.iloc[0]
pc2_variance = variance_explained.iloc[1]

WILD_COHORT.columns = [
    "FID", "IID",
    "PC1", "PC2", "PC3", "PC4", "PC5",
    "PC6", "PC7", "PC8", "PC9", "PC10"
]


WILD_COHORT["IID"] = WILD_COHORT["IID"].astype(str).str.strip()
WILD_metadata["IID"] = WILD_metadata["IID"].astype(str).str.strip()

#merge metadata and pca coordinates into one data frame
WILD_COHORT=WILD_COHORT.merge(WILD_metadata, on="IID", how="left")

breeds = WILD_COHORT["Breed"].unique()

palette = sns.color_palette("hls", len(breeds))

sns.scatterplot(
    data=WILD_COHORT,
    x="PC1",
    y="PC2",
    hue="Breed",
    palette=palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )


plt.xlabel(
    f"PC1 ({pc1_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC2 ({pc2_variance:.2f}%)", fontsize=14)
plt.title("Wild Only PCA, maf = 0.05, genotype = 0.1", fontsize=16, weight="bold")


plt.legend(
    title= "Breed",
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True,
    fontsize=9,
    title_fontsize=10,
)

sns.despine()
plt.tight_layout()
plt.savefig("Wild_Only_PCA_1_2.png", dpi=600, bbox_inches="tight")


#--------------------Wild Only Set PCs 3-4 -------------------#

pc3_variance = variance_explained.iloc[2]
pc4_variance = variance_explained.iloc[3]

sns.scatterplot(
    data=WILD_COHORT,
    x="PC3",
    y="PC4",
    hue="Breed",
    palette=palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )


plt.xlabel(
    f"PC3 ({pc3_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC4 ({pc4_variance:.2f}%)", fontsize=14)
plt.title("Wild Only PCA, maf = 0.05, genotype = 0.1", fontsize=16, weight="bold")


plt.legend(
    title= "Breed",
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True,
    fontsize=9,
    title_fontsize=10,
)

sns.despine()
plt.tight_layout()
plt.savefig("Wild_Only_PCA_3_4.png", dpi=600, bbox_inches="tight")



# #------------------------- Breed split plots ------- #

# #Read eigenvectors (PCA coordinates)
# pca = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/test4_norm/test4_bcftools_filter/final/final_pca.eigenvec", sep=r"\s+")
# #loading metadata, includes information on Breed and Group
# metadata = pd.read_csv("/mnt/autofs/data/userdata/project0076/annalise/filtering/plink_files_pca/metadata.csv")

# #merge metadata and pca coordinates into one data frame
# pca=pca.merge(metadata, on="IID", how="left")

# #Ordering breeds by sample size
# # breed_order = (pca["Breed"].value_counts().sort_values(ascending=False).index)

# # pca["Breed"] = pd.Categorical(pca["Breed"], categories=breed_order, ordered=True)

# sns.set_theme(style="white", context="paper", font_scale=1.4)

# # group_palette = {
# #     "Domestic": "#1b9e77",
# #     "Chaus": "#d95f02",
# #     "Margarita": "#ff0054",
# #     "Nigripes": "#00b4d8",
# #     "Silvestris": "#390099",
# #     "Bieti": "#fb6f92",
# #     "Lybica": "#008000",
# #     "Ornata": "#9e0059",
# #     "S.silvestris": "#ffba08",
# #     "S.ornata": "#0a9396",
# # }


# #Facet scatter plot

# g = sns.FacetGrid(
#     pca,
#     col="Breed",
#     col_wrap=5,
#     height=2.6,
#     margin_titles=True
# )

# g.map_dataframe(
#     sns.scatterplot,
#     x="PC1",
#     y="PC2",
#     hue="Breed",
#     palette=palette,
#     s=18,
#     alpha=0.75,
#     linewidth=0,
# )

# g.set_titles(
#     "{col_name}",
#     size=11,
#     weight="bold"
# )

# g.set_axis_labels(
#     "PC1",
#     "PC2"
# )

# for ax in g.axes.flat:
#     sns.despine(ax=ax)

# #Add legend
# handles, labels = g.axes[0].get_legend_handles_labels()

# g.figure.legend(
#     handles,
#     labels,
#     title="Breed",
#     loc="center right",
#     bbox_to_anchor=(1.00, 0.5),
#     frameon=True,
#     fontsize=10,
#     title_fontsize=11,
# )

# for ax in g.axes.flat:
#     if ax.legend_:
#         ax.legend_.remove()

# g.figure.suptitle(
#     "Filtered Cohort by Breed",
#     fontsize=15,
#     weight="bold",
#     y=1
# )

# plt.tight_layout()

# plt.savefig(
#     "final_filtered_by_breed_group.png",
#     dpi=600,
#     bbox_inches="tight"
# )

