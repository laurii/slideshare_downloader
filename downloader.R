######################
###
### SLideshare non downloadable slides downloader
### Author: Lauri Ilison
### Date: 24.06.2015
###
######################

## Importing libraries and if not then installing them
list.of.packages <- c('rvest','dplyr','pipeR', 'knitr', 'ReporteRs')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, library, character.only = T)


## Downloaded slideshare presentation
url <- "http://www.slideshare.net/0xdata/2015-02-19stratatalk"

## Creating temporary folder for downloading images
dir_string <- paste0(Sys.Date(),"_",sample(1:1000,1))
dir.create("data", recursive = FALSE, mode = "0777")
dir.create(paste0("data/",dir_string), showWarnings = TRUE, recursive = FALSE, mode = "0777")

## Downloading slideshare webpage
image_list <- url %>>%
    html %>>%
    html_nodes("img") %>>%
    html_attr(name = "data-normal",default = "NA")

## extracting images
df <- as.data.frame(image_list)
df$urls_na <- image_list == "NA"
df <- df[df$urls_na == FALSE,]

## Creating presentation that consist of images
## look the example http://davidgohel.github.io/ReporteRs/powerpoint.html

## Using template
dir.create(path = "templates",showWarnings=FALSE)
if(!file.exists('templates/template.pptx')){
    #  TODO: download the template from github and save into templates folder
}

mydoc = pptx(template = 'templates/template.pptx')

## creating Title slide:
slide.layouts(mydoc)
mydoc = addSlide(mydoc, "Title Slide")
mydoc = addDate(mydoc, Sys.Date())
mydoc = addTitle(mydoc,"Linkedin presentation")
mydoc = addSubtitle(mydoc, paste0("url = ",url))

## Creating image slides
for (i in 1:dim(df)[1]){
    mydoc = addSlide( mydoc, "Title and Content" )
    f = as.character(df[i,1])
    ## downloading images into temporary folder
    download.file(f,destfile=paste0("data/",dir_string,"/slide",i,".jpg"),method="curl")
    mydoc = addImage(mydoc, filename = paste0("data/",dir_string,"/slide",i,".jpg"))
}

## deleting images
unlink(paste0("data/",dir_string),recursive = TRUE)
## write mydoc
final_dir <- paste0("presentations/",dir_string)
dir.create(final_dir,recursive = TRUE)
presentation_filename <- paste0(final_dir,"/slideshare_slides_",sub(Sys.time(),pattern = " ",replacement = "_"),".pptx")
writeDoc( mydoc, presentation_filename )


