

#-------------
# Goals:
# 1. Input csv or tsv file and metadata
# 2. Output PCA plots for PC1-2 and PC3-4 for each cohort

# ------ Package install ------#

required_packages <- c(
    "pheatmap",
    "ggplot2",
    "ggrepel",
    #"viridis",
    "colorspace"
)

for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(
            "Required package '", pkg,
            "' is not installed in this environment."
        )
    }
}

library(pheatmap)
library(ggplot2)
library(ggrepel)
#library(viridis)
library(colorspace)



#------- Input file and output prefix -------#

felidae_file <-"/mnt/data/project0076/annalise/filtering/pipeline/results/mutyper/felidae_mutyper.NKnorm.deseq2.csv"
felis_file <- "/mnt/data/project0076/annalise/filtering/pipeline/results/mutyper/felis_mutyper.NKnorm.deseq2.csv"
metadata_file <- "/mnt/data/project0076/annalise/filtering/pipeline/plotting_scripts/metadata_filtered_mutyper.csv"

#----- output dir --------#

output_dir <-"/mnt/autofs/data/userdata/project0076/annalise/filtering/pipeline/plotting_scripts"

dir.create(
    output_dir,
    recursive = TRUE,
    showWarnings = FALSE
)


# ------ Reading Felidae input file -------#

felidae <- read.csv(
    felidae_file,
    header = TRUE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)


# ------ Reading Felis input file -------#

felis <- read.csv(
    felis_file,
    header = TRUE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)


# ------ Reading metadata file -------#

metadata <- read.csv(
    metadata_file,
    header = TRUE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)



prepare_spectrum <- function(data, metadata) {

    sample_ids <- as.character(data$sample)

    mutation_columns <- setdiff(
        colnames(data),
        "sample"
    )
    #Setting mutations numeric
    X <- data[
        , 
        mutation_columns, 
        drop =FALSE
    ]


    X[] <- lapply(
        X,
        function(x) {
            as.numeric(as.character(x))
        }
    )

    metadata_index <- match(
        sample_ids,
        metadata$sample
    )

    if (any(is.na(metadata_index))) {
        
        missing_samples <- sample_ids[
            is.na(metadata_index)
        ]

        stop(
            paste(
                "These samples are missing from metadata:",
                paste(
                    missing_samples, 
                    collapse = ","
                    )
                )
            )
    }

    sample_metadata <- metadata[
        metadata_index,
        ,
        drop = FALSE
    ]

    rownames(X) <- sample_ids
    rownames(sample_metadata) <- sample_ids

    return(
        list(
            matrix = X,
            metadata = sample_metadata
        )
    )
}

#------- Felis and felidae data prep ------#

felidae_data <- prepare_spectrum(
    felidae,
    metadata
)

felis_data <- prepare_spectrum(
    felis, metadata
)

make_group_pca <- function(
    X_pca,
    sample_metadata,
    group_name,
    reference_name,
    output_dir,
    breed_colours
) {



    keep <- !is.na(sample_metadata$Group) &
            sample_metadata$Group == group_name

    X_group <- X_pca[
        keep,
        ,
        drop = FALSE
    ]

    metadata_group <- sample_metadata[
        keep,
        ,
        drop = FALSE
    ]

    feature_variance <- apply(
        X_group,
        2,
        var
    )

    X_group <- X_group[
        ,
        !is.na(feature_variance) &
        feature_variance > 0,
        drop = FALSE
    ]

    if (ncol(X_group) < 2) {

        warning(
            "Skipping ",
            reference_name,
            " ",
            group_name,
            " PCA: fewer than 2 variable features."
        )

        return(NULL)
    }


# ---- pca plot ------#
    pca <- prcomp(
        X_group,
        center = TRUE,
        scale. = TRUE
    )

#------- setting variance -----#

    var_expl <- (
        pca$sdev^2 /
        sum(pca$sdev^2)
    ) * 100

# ------------------ data frame setup-----#

    pca_df <- data.frame(
        sample = rownames(pca$x),
        PC1 = pca$x[, 1],
        PC2 = pca$x[, 2],
        stringsAsFactors = FALSE
    )

    if (ncol(pca$x) >= 4) {

        pca_df$PC3 <- pca$x[, 3]
        pca_df$PC4 <- pca$x[, 4]

    }
#----- setting groups for shapes-----#

    pca_df$Group <- group_name

    metadata_group$sample <- rownames(metadata_group)

    pca_df$Breed <- metadata_group$Breed[
        match(
        pca_df$sample,
        metadata_group$sample
        )
    ]

    pca_df$Breed <- factor(
        pca_df$Breed
    )

    group_breeds <- unique(
        as.character(pca_df$Breed)
    )

    group_breed_colours <- breed_colours[
        names(breed_colours) %in% group_breeds
    ]


#---------- make pc 1 and 2 plot

    p12 <- ggplot(
        pca_df,
        aes(
            x = PC1,
            y = PC2,
            colour = Breed
        )
    ) +

        geom_point(
            size = 3.8,
            alpha = 0.75
        ) +

        scale_colour_manual(
            values = group_breed_colours
        ) +

        theme_classic(
            base_size = 20
        ) +

        theme(
            legend.position = "bottom",
            legend.direction = "horizontal",
            legend.title = element_text(size = 12),
            legend.text = element_text(size = 8),
            legend.key.size = unit(0.1, "cm"),
            legend.key.width = unit(0.1, "cm"),
            legend.spacing.x = unit(0.1, "cm"),
            legend.box.spacing = unit(0.1, "cm"),
            legend.margin = margin(0, 0, 0, 0),
            plot.title = element_text(
                size = 15,
                face = "bold"
            ),
            legend.box = "vertical",
            plot.margin = margin(5, 5, 5, 5),

            plot.background = element_rect(
                fill = "white",
                colour = NA
            ),

            panel.background = element_rect(
                fill = "white",
                colour = NA
            )
        ) +

        guides(
            colour = guide_legend(
                title = "Breed",
                ncol = 6,
                byrow = TRUE,
                override.aes = list(
                    size = 8,
                    alpha = 0.9
                )
            )
        ) +

        labs(

            title = paste0(
                "Mutation Spectrum PCA - ",
                group_name,
                " - ",
                reference_name,
                " Reference"
            ),

            x = paste0(
                "PC1 (",
                round(var_expl[1], 1),
                "% variance)"
            ),

            y = paste0(
                "PC2 (",
                round(var_expl[2], 1),
                "% variance)"
            ),

            colour = "Breed"
        )


#----- PC 1 and 2 ----- saving #

    pc12_file <- file.path(
        output_dir,
        paste0(
            reference_name,
            "_PCA_Deseq2_",
            group_name,
            "_1_2.png"
        )
    )

    ggsave(
        filename = pc12_file,
        plot = p12,
        width = 12,
        height = 12,
        dpi = 600
    )


#----------- PC 3 and 4-----#

    if (ncol(pca$x) >= 4) {

        p34 <- ggplot(
            pca_df,
            aes(
                x = PC3,
                y = PC4,
                colour = Breed
            )
        ) +

            geom_point(
                size = 3.8,
                alpha = 0.75
            ) +

            scale_colour_manual(
                values = breed_colours
            ) +

            theme_classic(
                base_size = 20
            ) +

            theme(
                legend.position = "bottom",
                legend.direction = "horizontal",
                legend.title = element_text(size = 12),
                legend.text = element_text(size = 8),
                legend.key.size = unit(0.1, "cm"),
                legend.key.width = unit(0.1, "cm"),
                legend.spacing.x = unit(0.1, "cm"),
                legend.box.spacing = unit(0.1, "cm"),
                legend.margin = margin(0, 0, 0, 0),
                plot.title = element_text(
                    size = 15,
                    face = "bold"
                ),
                legend.box = "vertical",
                plot.margin = margin(5, 5, 5, 5),

                plot.background = element_rect(
                    fill = "white",
                    colour = NA
                ),

                panel.background = element_rect(
                    fill = "white",
                    colour = NA
                )
            ) +

            guides(
                colour = guide_legend(
                    title = "Breed",
                    ncol = 6,
                    byrow = TRUE,
                    override.aes = list(
                        size = 8,
                        alpha = 0.9
                    )
                )
            ) +

            labs(

                title = paste0(
                    "Mutation Spectrum PCA - ",
                    group_name,
                    " - ",
                    reference_name,
                    " Reference"
                ),

                x = paste0(
                    "PC3 (",
                    round(var_expl[3], 1),
                    "% variance)"
                ),

                y = paste0(
                    "PC4 (",
                    round(var_expl[4], 1),
                    "% variance)"
                ),

                colour = "Breed"
            )

        pc34_file <- file.path(
            output_dir,
            paste0(
                reference_name,
                "_PCA_Deseq2_",
                group_name,
                "_3_4.png"
            )
        )


        ggsave(
            filename = pc34_file,
            plot = p34,
            width = 12,
            height = 14,
            dpi = 600
        )

    } else {

        cat(
            "PC3-PC4 not saved: fewer than 4 PCs available.\n"
        )
    }

    invisible(pca)
}


#----- Analysis function
analyse_spectrum <- function(
    spectrum,
    reference_name,
    output_dir
 ) {

    print(class(spectrum))
    print(names(spectrum))
    #-----extract matrix and metadata ------#

    X <- spectrum$matrix

    sample_metadata <- spectrum$metadata


    #----- remove mutations with only NA values ------#

    all_na <- apply(
        X,
        2,
        function(x) all(is.na(x))
    
    )
    if (any(all_na)) {
        X <- X[, !all_na, drop = FALSE]
    }

    X[is.na(X)] <- 0


#----- PCA --------------------#

#------ want to log transform??? -----#
use_log_transform <- FALSE
    if (use_log_transform) {
        X_pca <- log10(X + 1e-10)

    } else {
        X_pca <- X
    }

#------ Remove zero variance features ------#

    feature_variance <- apply(
        X_pca,
        2,
        var
    )

    X_pca <- X_pca[
        ,
        feature_variance > 0,
        drop = FALSE
    ]

    #-------groups-----#

domestic_breeds <- sort(
    unique(
        na.omit(
            as.character(
                sample_metadata$Breed[
                    sample_metadata$Group == "Domestic"
                ]
            )
        )
    )
)

wild_breeds <- sort(
    unique(
        na.omit(
            as.character(
                sample_metadata$Breed[
                    sample_metadata$Group == "Wild"
                ]
            )
        )
    )
)


#----------- splitting domestic into groups of 6-----#
domestic_groups <- split(
    domestic_breeds,
    ceiling(
        seq_along(domestic_breeds) / 6
    )
)


# ----- palette colors ------#
domestic_palette_names <- c(
    "Mako",
    "Emrld",
    "Batlow",
    "Red-Blue",
    "Hawaii",
    "Terrain",
    "Purple-Blue",
    "Purp"
)


domestic_colours <- c()

for (i in seq_along(domestic_groups)) {

    breeds_in_group <- domestic_groups[[i]]

    n_breeds <- length(
        breeds_in_group
    )

    colours <- grDevices::hcl.colors(
        n_breeds,
        palette = domestic_palette_names[i]
    )

    names(colours) <- breeds_in_group

    domestic_colours <- c(
        domestic_colours,
        colours
    )
}


if (length(wild_breeds) > 0) {

    wild_colours <- grDevices::hcl.colors(
        length(wild_breeds),
        palette = "Inferno"
    )

    names(wild_colours) <- wild_breeds

} else {

    wild_colours <- c()

}

breed_colours <- c(
    domestic_colours,
    wild_colours
)

#------- make domestic group PCA------#
make_group_pca(
    X_pca = X_pca,
    sample_metadata = sample_metadata,
    group_name = "Domestic",
    reference_name = reference_name,
    output_dir = output_dir,
    breed_colours = breed_colours
)
# ------ make wild group PCA-----#
make_group_pca(
    X_pca = X_pca,
    sample_metadata = sample_metadata,
    group_name = "Wild",
    reference_name = reference_name,
    output_dir = output_dir,
    breed_colours = breed_colours
)

    #-------PCA-------# (Samples are rows, mut type are variables)

    pca <- prcomp(
        X_pca,
        center = TRUE,
        scale. = TRUE
    )


    # PC1 feature loadings
    pc1_loadings <- sort(
        abs(pca$rotation[, 1]),
        decreasing = TRUE
    )

    print(
        head(pc1_loadings, 20)
    )

    print(
        tail(pc1_loadings, 20)
    )
    #------Percent variance explain-----

    var_expl <- (
        pca$sdev^2 /
        sum(pca$sdev^2)
    ) * 100


    #----------PCA Data frame-----------#
    pca_df <- data.frame(
        sample = rownames(pca$x),
        PC1 = pca$x[, 1],
        PC2 = pca$x[, 2],
        stringsAsFactors = FALSE
    )

    # ------- merge metadata --------#
    pca_df$Group <- sample_metadata[
        pca_df$sample,
        "Group"
    ]



    pca_df$Breed <- sample_metadata[
        pca_df$sample,
        "Breed"
    ]

    pca_df$Breed <- factor(pca_df$Breed)
    pca_df$Group <- factor(pca_df$Group)

    domestic_breeds <- sort(
        unique(
            as.character(
                sample_metadata$Breed[
                    sample_metadata$Group == "Domestic"
                ]
            )
        )
    )
    

    wild_breeds <- sort(
        unique(
            as.character(
                sample_metadata$Breed[
                    sample_metadata$Group == "Wild"
                ]
            )
        )
    )

    domestic_groups <- split(
        domestic_breeds,
        ceiling(
            seq_along(domestic_breeds) / 6
        )
    )
# ----- setting palettes
    domestic_palette_names <- c(
        "Mako",
        "Emrld",
        "Batlow",
        "Red-Blue",
        "Hawaii",
        "Terrain",
        "Purple-Blue",
        "Purp"
    )

    domestic_colours <- c()

    for (i in seq_along(domestic_groups)) {

        breeds_in_group <- domestic_groups[[i]]

        n_breeds <- length(
            breeds_in_group
        )

        colours <- grDevices::hcl.colors(
            n_breeds,
            palette = domestic_palette_names[i]
        )
        names(colours) <- breeds_in_group

        # --- combinging the domestic and wild colours into one object
        domestic_colours <- c(
            domestic_colours,
            colours
        )
    }

    if (length(wild_breeds) > 0) {

        wild_colours <- grDevices::hcl.colors(
            length(wild_breeds),
            palette = "Inferno"
        )

        names(wild_colours) <- wild_breeds
    } else {
        
        wild_colours <- c()
    }

    breed_colours <- c(
        domestic_colours,
        wild_colours
    )

    make_group_pca(
        X_pca = X_pca,
        sample_metadata = sample_metadata,
        group_name = "Domestic",
        reference_name = reference_name,
        output_dir = output_dir,
        breed_colours = breed_colours
    )

    make_group_pca(
    X_pca = X_pca,
    sample_metadata = sample_metadata,
    group_name = "Wild",
    reference_name = reference_name,
    output_dir = output_dir,
    breed_colours = breed_colours
    )

    # ---- relating breed to group
    breed_group <- aggregate(
        Group ~ Breed,
        data = pca_df,
        FUN = function(x) unique(x)[1]
    )


    breed_group_lookup <- tapply(
        as.character(pca_df$Group),
        as.character(pca_df$Breed),
        function(x) unique(x)[1]
    )

    missing_groups <- setdiff(
        names(breed_colours),
        names(breed_group_lookup)
    )

    if (length(missing_groups) >0) {
        stop(
            "Couldn't determine Group for breeds: ",
            paste(missing_groups, collapse = ", ")
        )
    }

    #---setting shapes -----#

    group_shapes <- c(
        Domestic = 16,
        Wild = 17
    )


    breed_shapes <- group_shapes[
        breed_group_lookup[
            names(breed_colours)
        ]
    ]

    breed_shapes <- unname(breed_shapes)


    #----- PCA plot ------#

    p <- ggplot(
        
        pca_df,
        aes(
            x = PC1,
            y = PC2,
        )
    ) +
        #black outline
        # geom_point(
        #     aes(
        #         shape = Group
        #     ),
        #     size = 4.2,
        #     fill = NA,
        #     colour = "black",
        #     stroke = 1,
        #     alpha = 1
        # ) +
        #colour points
        geom_point(
            aes(
                colour = Breed,
                shape = Group
            ),
            size = 3.8,
            stroke = 0.7,
            alpha = 0.75
        ) +

        # scale_colour_viridis_d(
        #     option = "turbo",
        #     end = 0.95
        # ) +

        scale_colour_manual(
            values = breed_colours,
            breaks = names(breed_colours)
        ) +

        scale_shape_manual(
            values = group_shapes,
            breaks = c("Domestic", "Wild")
    
        ) +


        theme_classic(base_size=20) +

        #-----legend formatting----#

        theme(
            legend.position = "bottom",
            legend.direction = "horizontal",
            legend.title = element_text(size = 12),
            legend.text = element_text(size = 8),
            legend.key.size = unit(0.1, "cm"),
            legend.key.width = unit(0.1, "cm"),
            legend.spacing.x = unit(0.1, "cm"),
            legend.box.spacing = unit(0.1, "cm"),
            legend.margin = margin(0, 0, 0, 0),
            plot.title = element_text(size = 15, face = "bold"),
            legend.box = "vertical",
            plot.margin = margin(5, 5, 5, 5),

            plot.background = element_rect(
                fill = "white",
                colour = NA
            ),

            panel.background = element_rect(
                fill = "#b5b1b1",
                colour = NA
            ),
        ) +

        guides(
            colour = guide_legend(
                title = "Breed",
                ncol = 6,
                byrow = TRUE,
                override.aes = list(
        
                    size = 8,
                    alpha = 0.9
                )
            ),

            shape = guide_legend(
                title = "Group",
                ncol = 2,
                byrow = TRUE,
                override.aes = list(
                    size = 5
                )
            )
        ) +

        #--- labels----#
        labs(

            title = paste0(
                "Mutation Spectrum PCA - Deseq2-like Normalization ",
                reference_name,
                " Reference "
            ),
        

            x = paste0(
                "PC1 (",
                round(var_expl[1], 1),
                "% variance)"
            ),

            y = paste0(
                "PC2 (",
                round(var_expl[2], 1),
                "% variance)"
            ),

        colour = "Breed",
        shape = "Group"

    )

    #save plot

    pca_file <- file.path(
        output_dir,
        paste0(
            reference_name,
            "_PCA_Deseq2_1_2.png"
        )
    )

    ggsave(
        pca_file,
        p,
        width = 12,
        height =16,
        dpi = 600
    )

 }

print(class(felidae_data))
print(names(felidae_data))

print(class(felis_data))
print(names(felis_data))





analyse_spectrum(
    felidae_data,
    "Felidae",
    output_dir
)

analyse_spectrum(
    felis_data,
    "Felis",
    output_dir
)
