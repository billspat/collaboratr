## code to prepare data

commecology_rules_biomass_str <- readr::read_csv('data-raw/commecology_rules_biomass_str.csv')
usethis::use_data(commecology_rules_biomass_str, overwrite = TRUE)

biomass_validator_file <- 'data-raw/biomass_validation_rules.yaml'
biomass_validator <- validate::validator(.file= biomass_validator_file )
usethis::use_data(biomass_validator, overwrite = TRUE)


prep_iris_species_df <-function(genus){
  df <- data.frame(iris3[,,genus])
  df$group_id <- rep(genus, nrow(df))
  df$whos <- rep('ESA', nrow(df))
  df$site <- rep('Missouri Botanical Garden', nrow(df))
  df$site <- rep('Missouri Botanical Garden', nrow(df))
  return(df)
}


readr::write_csv( prep_iris_species_df("Setosa"), "data_raw/Setosa.csv")
readr::write_csv( prep_iris_species_df("Versicolor"), "data_raw/Versicolor.csv")
readr::write_csv( prep_iris_species_df("Virginica"), "data_raw/Virginica.csv")

