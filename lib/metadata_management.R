#' Utility functions for metadata management
#' Currently works only for 16S rRNA (adding GA-map now)

combine_dataframes <- function(df_main, df_new){
  if(is.null(df_main) || nrow(df_main) == 0) 
    return (df_new)
  
  return(rbind(df_main, df_new))
}

add_diet_response <- function(df){
  df_res <- df
  df$delta_IBS_SSS <- (df$pre_diet_IBS_SSS - df$post_diet_IBS_SSS)
  df_res$Response <- cut(df$delta_IBS_SSS,
                     breaks = c(-Inf, 
                                No_Response_Max_Improvement,
                                Low_Response_Max_Improvement, 
                                Inf),
                     labels = c("No", "Low", "High"))
  return(df_res)
}

load_study_metadata <- function(study_id, config){
  df_meta <- read.table(config$metadata_filepath, sep = ",", header = TRUE, 
                        na.strings = "")
  df_meta$study_name <- study_id
  df_meta$technology <- config$Technology
  df_meta$reference <- config$Reference
  df_meta$pre_mic_avail <- !is.na(df_meta$pre_diet_microbiome_sample_id)
  df_meta$host_id <- sprintf("%s_%s", df_meta$study_name, df_meta$host_id)
  
  return(df_meta)
}

load_metadata <- function(){
  # 1) Combine metadata from all studies
  df_comb_metadata <- data.frame()
  study_configs <- load_study_configs()
  for(sid in names(study_configs)){
    df_study_metadata <- load_study_metadata(sid, study_configs[[sid]])
    df_comb_metadata <- combine_dataframes(df_comb_metadata, df_study_metadata)
  }

  # 2) Identify response labels (No/Low/High)
  df_comb_metadata <- add_diet_response(df_comb_metadata)
  
  # 3) Return
  return(df_comb_metadata)
}