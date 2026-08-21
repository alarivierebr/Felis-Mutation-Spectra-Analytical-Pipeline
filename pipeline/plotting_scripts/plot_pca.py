import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import colorcet as cc
from matplotlib.patches import Ellipse
import os
from mpl_toolkits.axes_grid1.inset_locator import inset_axes, mark_inset
from matplotlib.patches import Rectangle

outdir = "/mnt/autofs/data/userdata/project0076/annalise/filtering/pipeline/results/plots"


#------------- Loading Files------------------#

# --------------------- Full cohort-----------------#

FULL_COHORT = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_1/before_filter_pca.eigenvec", sep=r"\s+")
FULL_EIGENVAL = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_1/before_filter_pca.eigenval", header=None)
#loading metadata, includes information on Breed and Group, cleaning
FULL_metadata = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/plotting_scripts/metadata2.csv")

FULL_COHORT = FULL_COHORT.drop_duplicates(subset="IID", keep="first")
FULL_metadata = FULL_metadata.drop_duplicates(subset="IID", keep="first")

#----- Filtering out Savannah -----#
# exclude_iid = ["SAMN14425583"]

# FULL_COHORT = FULL_COHORT[~FULL_COHORT["IID"].isin(exclude_iid)]

# -------------- Full cohort Post Filter --------------------#

FILTER_COHORT = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_nO/nO_filtered_pca.eigenvec", sep=r"\s+")
FILTER_EIGENVAL = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_nO/nO_filtered_pca.eigenval", header=None)
FILTER_metadata = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/plotting_scripts/metadata2.csv")

FILTER_COHORT = FILTER_COHORT.drop_duplicates(subset="IID", keep="first")
FILTER_metadata = FILTER_metadata.drop_duplicates(subset="IID", keep="first")


#---------------- Domestic Only Cohort ---------------------#

DOM_COHORT = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_filtered/dom_only/nO_dom_only.eigenvec", sep=r"\s+")
DOM_EIGENVAL = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_filtered/dom_only/nO_dom_only.eigenval", header=None)
DOM_metadata = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/plotting_scripts/metadata_domestic_grouped.csv")

DOM_COHORT = DOM_COHORT.drop_duplicates(subset="IID", keep="first")
DOM_metadata = DOM_metadata.drop_duplicates(subset="IID", keep="first")

# ####-------REMOVING TURKISH ANGORA and TOYGER CAUSE THEY ARE STILL OUTLIERS------##########
# exclude_iid = ["SAMN14425597", "SAMN14425596", "SAMN04022998", "SAMN05980314", "SRS9467141"]

# DOM_COHORT = DOM_COHORT[~DOM_COHORT["IID"].isin(exclude_iid)]

#-----------------Wild Only Cohort ---------------------#

WILD_COHORT = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_filtered/wild_only/nO_wild_only.eigenvec", sep=r"\s+", header=0)
WILD_EIGENVAL = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/results/plink_filtered/wild_only/nO_wild_only.eigenval", header=None)
WILD_metadata = pd.read_csv("/mnt/data/project0076/annalise/filtering/pipeline/plotting_scripts/metadata_wild.csv")

WILD_COHORT = WILD_COHORT.drop_duplicates(subset="IID", keep="first")
WILD_metadata = WILD_metadata.drop_duplicates(subset="IID", keep="first")


#-------------Full Cohort----------#
variance_explained = FULL_EIGENVAL[0] / FULL_EIGENVAL[0].sum() * 100

pc1_variance = variance_explained.iloc[0]
pc2_variance = variance_explained.iloc[1]


FULL_COHORT=FULL_COHORT.merge(FULL_metadata, on="IID", how="left", validate="one_to_one")

sns.set_theme(style="white", context="paper", font_scale=1.3)

fig, ax = plt.subplots(figsize=(8, 7))

groups = FULL_COHORT["Group"].unique()

other_group = [g for g in groups if g != "Domestic"]

other_palette = sns.color_palette("nipy_spectral", len(other_group))

group_palette = {"Domestic": "grey"}
group_palette.update(dict(zip(other_group, other_palette))
)


sns.scatterplot(
    data=FULL_COHORT,
    x="PC1",
    y="PC2",
    hue="Group",
    palette=group_palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )



plt.xlabel(
    f"PC1 ({pc1_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC2 ({pc2_variance:.2f}%)", fontsize=14)
plt.title("PCA - Full Cohort, Pre-Filter", fontsize=16, weight="bold")

plt.legend(
    title= "Group",
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True,
    fontsize=9,
    title_fontsize=10,
)
x_min = -0.027
x_max = -0.010

y_min = -0.01
y_max = 0.010


axins = inset_axes(
    ax,
    width="40%",
    height="40%",
    loc="upper center"
)

sns.scatterplot(
    data=FULL_COHORT,
    x="PC1",
    y="PC2",
    hue="Group",
    palette=group_palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black",
    legend=False
    )


axins.set_xlim(x_min, x_max)
axins.set_ylim(y_min, y_max)

axins.set_xlabel("PC1", fontsize=9)
axins.set_ylabel("PC2", fontsize=9)
axins.tick_params(axis="both",labelsize=6)

mark_inset(
    ax,
    axins,
    loc1=2,
    loc2=4,
    fc="none",
    ec="black",
    linewidth=1
)

plt.tight_layout()


sns.despine()
plt.tight_layout()
plt.savefig(os.path.join(outdir,"Before_filter_1_2"), dpi=600, bbox_inches="tight")
plt.close()

#--------- PC3 and 4 -------------------#
pc3_variance = variance_explained.iloc[2]
pc4_variance = variance_explained.iloc[3]

sns.set_theme(style="white", context="paper", font_scale=1.3)

plt.figure(figsize=(8, 7))

sns.scatterplot(
    data=FULL_COHORT,
    x="PC3",
    y="PC4",
    hue="Group",
    palette=group_palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )

plt.xlabel(
    f"PC3 ({pc3_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC4 ({pc4_variance:.2f}%)", fontsize=14)
plt.title("PCA - Full Cohort, Pre-Filter", fontsize=16, weight="bold")

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
plt.savefig(os.path.join(outdir,"Before_filter_3_4"), dpi=600, bbox_inches="tight")
plt.close()


#------------------- Full cohort Post Filter-----------------------#

variance_explained = FILTER_EIGENVAL[0] / FILTER_EIGENVAL[0].sum() * 100

pc1_variance = variance_explained.iloc[0]
pc2_variance = variance_explained.iloc[1]

FILTER_COHORT=FILTER_COHORT.merge(FILTER_metadata, on="IID", how="left", validate="one_to_one")

sns.set_theme(style="white", context="paper", font_scale=1.3)

plt.figure(figsize=(8, 7))

groups = FILTER_COHORT["Group"].unique()

other_group = [g for g in groups if g != "Domestic"]

other_palette = sns.color_palette("nipy_spectral", len(other_group))

group_palette = {"Domestic": "grey"}
group_palette.update(dict(zip(other_group, other_palette))
)


sns.scatterplot(
    data=FILTER_COHORT,
    x="PC1",
    y="PC2",
    hue="Group",
    palette=group_palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )

plt.xlabel(
    f"PC1 ({pc1_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC2 ({pc2_variance:.2f}%)", fontsize=14)
plt.title("PCA - Filtered Cohort", fontsize=16, weight="bold")

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
plt.savefig(os.path.join(outdir, "After_filter_1_2"), dpi=600, bbox_inches="tight")
plt.close()

#--------- PC3 and 4 -------------------#

variance_explained = FILTER_EIGENVAL[0] / FILTER_EIGENVAL[0].sum() * 100

pc3_variance = variance_explained.iloc[2]
pc4_variance = variance_explained.iloc[3]

sns.set_theme(style="white", context="paper", font_scale=1.3)

plt.figure(figsize=(8, 7))

groups = FILTER_COHORT["Group"].unique()


sns.scatterplot(
    data=FILTER_COHORT,
    x="PC3",
    y="PC4",
    hue="Group",
    palette=group_palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black"
    )

plt.xlabel(
    f"PC3 ({pc3_variance:.2f}%)", fontsize=14)
plt.ylabel(
    f"PC4 ({pc4_variance:.2f}%)", fontsize=14)
plt.title("PCA - Filtered Cohort", fontsize=16, weight="bold")

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
plt.savefig(os.path.join(outdir,"After_filter_3_4"), dpi=600, bbox_inches="tight")
plt.close()


#--------------------Domestic Only Set-------------------#

variance_explained = DOM_EIGENVAL[0] / DOM_EIGENVAL[0].sum() * 100

pc1_variance = variance_explained.iloc[0]
pc2_variance = variance_explained.iloc[1]


DOM_COHORT.columns = [
    "FID", "IID",
    "PC1", "PC2", "PC3", "PC4", "PC5",
    "PC6", "PC7", "PC8", "PC9", "PC10"
]

#merge metadata and pca coordinates into one data frame
DOM_COHORT = DOM_COHORT.merge(DOM_metadata, on="IID", how="left", validate= "one_to_one")

sns.set_theme(style="white", context="paper", font_scale=1.3)

fig, ax = plt.subplots(figsize=(10, 8))

breeds = DOM_COHORT["Breed"].unique()

palette = cc.glasbey_bw_minc_20_maxl_70[:DOM_COHORT["Breed"].nunique()]
breed_palette = dict(zip(breeds, palette))


#-------- Main plot-----#
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

#------ Inset--------#
x_min = -0.04
x_max = -0.01

y_min = -0.050
y_max = 0.03


axins = inset_axes(
    ax,
    width="40%",
    height="40%",
    loc="upper right"
)

sns.scatterplot(
    data=DOM_COHORT,
    x="PC1",
    y="PC2",
    hue="Breed",
    palette=breed_palette,
    s=30,
    alpha=0.8,
    linewidth=0.5,
    edgecolor="black",
    legend=False,
    ax=axins
    )


axins.set_xlim(x_min, x_max)
axins.set_ylim(y_min, y_max)

axins.set_xlabel("PC1", fontsize=9)
axins.set_ylabel("PC2", fontsize=9)
axins.tick_params(axis="both",labelsize=8)

mark_inset(
    ax,
    axins,
    loc1=2,
    loc2=4,
    fc="none",
    ec="black",
    linewidth=1
)

plt.tight_layout()


sns.despine()
plt.tight_layout()
plt.subplots_adjust(bottom=0.25)
plt.savefig(os.path.join(outdir,"nO_Dom_Only_PCA_1_2.png"), dpi=600, bbox_inches="tight")

plt.close()

#--------------------Domestic Only Set PC3 and 4------------------

variance_explained = DOM_EIGENVAL[0] / DOM_EIGENVAL[0].sum() * 100

pc3_variance = variance_explained.iloc[2]
pc4_variance = variance_explained.iloc[3]

#merge metadata and pca coordinates into one data frame

sns.set_theme(style="white", context="paper", font_scale=1.3)

plt.figure(figsize=(10, 8))

breeds = DOM_COHORT["Breed"].unique()

palette = cc.glasbey_bw_minc_20_maxl_70[:DOM_COHORT["Breed"].nunique()]
breed_palette = dict(zip(breeds, palette))

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
plt.savefig(os.path.join(outdir,"nO_Dom_Only_PCA_3_4.png"), dpi=600, bbox_inches="tight")

plt.close()
#--------------------Wild Only Set-------------------#

variance_explained = WILD_EIGENVAL[0] / WILD_EIGENVAL[0].sum() * 100

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
WILD_COHORT=WILD_COHORT.merge(WILD_metadata, on="IID", how="left", validate="one_to_one")

sns.set_theme(style="white", context="paper", font_scale=1.3)

fig, ax = plt.subplots(figsize=(8, 7))

breeds = WILD_COHORT["Breed"].unique()

palette = sns.color_palette("gnuplot2", len(breeds))

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

x_min = -0.035
x_max = -0.005

y_min = -0.055
y_max = -0.025


axins = inset_axes(
    ax,
    width="40%",
    height="40%",
    loc="upper right"
)

sns.scatterplot(
    data=WILD_COHORT,
    x="PC1",
    y="PC2",
    hue="Breed",
    palette=palette,
    s=35,
    alpha=0.8,
    linewidth=0.2,
    edgecolor="black",
    legend=False
    )


axins.set_xlim(x_min, x_max)
axins.set_ylim(y_min, y_max)

axins.set_xlabel("PC1", fontsize=9)
axins.set_ylabel("PC2", fontsize=9)
axins.tick_params(axis="both",labelsize=6)

mark_inset(
    ax,
    axins,
    loc1=2,
    loc2=4,
    fc="none",
    ec="black",
    linewidth=1
)

plt.tight_layout()

sns.despine()
plt.tight_layout()
plt.savefig(os.path.join(outdir,"nO_Wild_Only_PCA_1_2.png"), dpi=600, bbox_inches="tight")

plt.close()
#--------------------Wild Only Set PCs 3-4 -------------------#
variance_explained = WILD_EIGENVAL[0] / WILD_EIGENVAL[0].sum() * 100

pc3_variance = variance_explained.iloc[2]
pc4_variance = variance_explained.iloc[3]

plt.figure(figsize=(8, 7))

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
plt.savefig(os.path.join(outdir,"nO_Wild_Only_PCA_3_4.png"), dpi=600, bbox_inches="tight")


plt.close()
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

