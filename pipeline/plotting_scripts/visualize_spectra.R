#!/user/bin/env Rscript

#-------------
# Goals:
# 1. Input csv or tsv file
# 2. Output heatmap
# 3. Output PCA plot

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

felidae_file <-"/mnt/data/project0076/annalise/filtering/mutyper/spectra/nO_felidae_mut.NKnorm.deseq2.csv"
felis_file <- "/mnt/data/project0076/annalise/filtering/mutyper/spectra/nO_felis_mut.NKnorm.deseq2.csv"
metadata_file <- "/mnt/autofs/data/userdata/project0076/annalise/filtering/mutation_calc/metadata_rplots_grouped.csv"

#----- output dir --------#

output_dir <-"/mnt/autofs/data/userdata/project0076/annalise/filtering/R_plots"

dir.create(
    output_dir,
    recursive = TRUE,
    showWarnings = FALSE
)

#----- heatmap settings -----#

n_heatmap_features <- 30


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
    sample_ids <- data$sample

    mutation_columns <- setdiff(
        colnames(data),
        "sample"
    )
    #Setting mutations numeric
    X <- data[, mutation_columns, drop =FALSE]



    X[] <- lapply(
        X,
        function(x) as.numeric(as.character(x))
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
                paste(missing_samples, collapse = ",")
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

    #------- Felis and felidae data data prep ------#

    felidae_data <- prepare_spectrum(
        felidae,
        metadata
    )

    felis_data <- prepare_spectrum(
        felis, metadata
    )


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
                pca_df$Breed[
                    pca_df$Group == "Domestic"
                ]
            )
        )
    )
    


    wild_breeds <- sort(
        unique(
            as.character(
                pca_df$Breed[
                    pca_df$Group == "Wild"
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
            palette = "Plasma"
        )

        names(wild_colours) <- wild_breeds
    } else {
        
        wild_colours <- c()
    }

    breed_colours <- c(
        domestic_colours,
        wild_colours
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

#----- old shapes and breed groups -----#

    # breed_group <- breed_group[
    #     match(
    #         names(breed_colours),
    #         breed_group$Breed
    #     ),
    #     ,
    #     drop = FALSE
    # ]


    #---setting shapes -----#

    group_shapes <- c(
        Domestic = 16,
        Wild = 17
    )

    # breed_shapes <- group_shapes[
    #     as.character(
    #         breed_group$Group
    #     )
    # ]

    # names(breed_shapes) <- breed_group$Breed

#----- old pcas -------#
    # hcl_palettes("sequential (multi-hue)", n = 40, plot = TRUE)

    # # Generate colours for each group
    # domestic_colours <- grDevices::hcl.colours(
    #     length(domestic_breeds),
    #     palette = "Heat 2"
    # )

    # wild_colours <- grDevices::hcl.colours(
    #     length(wild_breeds),
    #     palette = "Blues"
    # )

    # Combine into one named vector
    # breed_colours <- c(
    #     setNames(domestic_colours, domestic_breeds),
    #     setNames(wild_colours, wild_breeds)
    # )

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
        geom_point(
            aes(
                shape = Group
            ),
            size = 4.2,
            fill = NA,
            colour = "black",
            stroke = 1,
            alpha = 1
        ) +
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
            values = group_shapes
    
        ) +

        # scale_x_continuous(
        #     minor_breaks = scales::breaks_extended(n = 10)
        # ) +

        # scale_y_continuous(
        #     minor_breaks = scales::breaks_extended(n = 10)
        # ) +

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
                fill = "white",
                colour = NA
            ),
        ) +

        guides(
            colour = guide_legend(
                title = "Breed",
                ncol = 6,
                byrow = TRUE,
                override.aes = list(
                    shape = breed_shapes,
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
                "Deseq No Log transform Mutation Spectrum PCA -",
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
            "_PCA_deseq2_nologtrans.png"
        )
    )

    ggsave(
        pca_file,
        p,
        width = 12,
        height =16,
        dpi = 600
    )



# ------ Centroid plot -------#

    # ---- one label per breed ----#

    breed_center <- aggregate(
        cbind(PC1, PC2) ~ Breed,
        data = pca_df,
        FUN = mean
    )

    breed_labels <- do.call(
        rbind,
        lapply(
            unique(pca_df$Breed),
            function(breed) {

                samples <- pca_df[
                    pca_df$Breed == breed,
                    ,
                    drop = FALSE
                ]

                centroid <- breed_center[
                    breed_center$Breed == breed,
                    ,
                    drop = FALSE
                ]

                distance <- (
                    (samples$PC1 - centroid$PC1)^2 +
                    (samples$PC2 - centroid$PC2)^2
                )

                samples[which.min(distance), ]
            }
        )
    )

    print(breed_labels)


    centroid_plot <- ggplot(
        breed_center,
        aes(
            x = PC1,
            y = PC2
        )
    ) +

        geom_point(
            shape = 21,
            size = 6,
            stroke = 1.2,
            colour ="black",
            fill = "white"
        ) +

        geom_text_repel(
            data = breed_labels,
            aes(
                x = PC1,
                y = PC2,
                label = Breed
            ),
            inherit.aes = FALSE,
            size = 3,
            colour = "black",
            fontface = "bold",
            box.padding = 0.7,
            point.padding =0.3,
            force = 2,
            force_pull = 0.5,
            max.overlaps = Inf,
            min.segment.length = 0,
            segment.size = 0.3
        ) +

        theme_classic(base_size = 16) +

        theme(
            plot.title = element_text(
                size = 16,
                face = "bold"
            )
        ) +

        labs(
            title = paste0(
                "Breed centroids - ",
                reference_name,
                " reference"
            ),

            x = paste0(
                "PC1 (",
                round(var_expl[1], 1),
                "%)"
            ),

            y = paste0(
                "PC2 (",
                round(var_expl[2], 1),
                "%)"
            ),

        )
        centroid_file <- file.path(
            output_dir,
            paste0(
                reference_name,
                "_PCA_centroids.png"
            )
        )

        ggsave(
            centroid_file,
            centroid_plot,
            width = 12,
            height = 14,
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


#     # ---- Setting up data frame ----- #

#     sample_names <- data[[1]]

#     mutation_data <- data[, -1, drop=FALSE]

#     rownames(mutation_data) <- sample_names

#     mutation_data <- as.data.frame(
#         lapply(mutation_data, as.numeric),
#         check.names = FALSE
#     )

#     rownames(mutation_data) <- sample_names

# # ------- Heatmap -----#

# heatmap_matrix <- as.matrix(mutation_data)

# pheatmap(
#     heatmap_matrix,
#     scale = "column",
#     clustering_distance_rows = "euclidean",
#     clustering_distance_cols = "euclidean",
#     clustering_method = "complete",
#     fontsize_row = 10,
#     fontsize_col = 8,
#     angle_col = 45,
#     main = paste(output_prefix, "mutation spectrum"),
#     filename = paste0(output_prefix, "_heatmap.png"),
#     width = 16,
#     height = 16
# )