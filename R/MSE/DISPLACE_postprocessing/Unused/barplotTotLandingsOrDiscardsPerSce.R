

#' Making an overview barplot for total landings per scenario for a selected set of stocks
#'
#' This function processes further the lst_loglike objects
#'
#' @param fname First name
#' @param lname Last name
#' @export
#' @examples
#'
#' \dontrun{
#' general <- setGeneralOverallVariable (main_path_outputs =file.path("C:","DISPLACE_outputs"),
#'                                       case_study="DanishFleet",
#'                                       igraph=41,
#'                                       a.year="2015",
#'                                       a.country="DEN",
#'                                       nbpops=39,
#'                                       nbszgroup=14,
#'                                       namefolderinput="DanishFleet",
#'                                       the_scenarios= c("svana_baseline",
#'                                                       "svana_sub1mx20",
#'                                                       "svana_sub4mx20",
#'                                                       "svana_sub4mx5ns20bt",
#'                                                       "svana_sub4mx20ns5bt",
#'                                                       "svana_sub4mx5ns5bt" ),
#'                                       nbsimus=20
#'                                       )
#'
#'
#'
#'   loadLoglikeFiles(general=general, use_port_info=FALSE)
#'
#'
#'
#'   barplotTotLandingsPerSce (general=general,
#'                                    selected="_selected_set1_",
#'                                     selected_pops=c(0:38),
#'                                    group1= c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
#'                                    selected_scenarios=general$namefolderoutput,
#'                                    nby=5, firsty="2015", lasty="2019",
#'                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,305))
#'
#'  Note that if black_and_white at true then the barplot is split into 2 groups
#' (first group is group1 stocks, second is all other ones)
#'
#' barplotTotLandingsPerSce (general=general,
#'                                    selected="_selected_set2_",
#'                                     selected_pops=c(0:38),
#'                                    group1= c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
#'                                    selected_scenarios=general$namefolderoutput,
#'                                    nby=5, firsty="2015", lasty="2019",
#'                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,305))
#'
#' barplotTotLandingsPerSce (general=general,
#'                                    selected="_selected_set3_",
#'                                     selected_pops=c(0:38),
#'                                    group1= c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
#'                                    selected_scenarios=general$namefolderoutput,
#'                                    nby=5, firsty="2015", lasty="2019",
#'                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,305))
#'
#'
#'   }





barplotTotLandingsPerSce <- function(general=general,
                                    type_of_column="pop", # or "disc"
                                    selected="_selected_set1_",
                                    selected_pops=c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
                                    group1= c(0, 1, 2, 3, 11, 23, 24, 26, 30, 31, 32),
                                    selected_scenarios=general$namefolderoutput,
                                    scenarios_names=general$namefolderoutput,
                                    nby=5, firsty="2015", lasty="2019",
                                    a_width=3500, a_height=2000, black_and_white = TRUE, ylims = c(0,10)){



   c.listquote <- function (...)
   {
    args <- as.list(match.call()[-1])
    lstquote <- list(as.symbol("list"))
    for (i in args) {
        if (class(i) == "name" || (class(i) == "call" && i[[1]] !=
            "list")) {
            i <- eval(substitute(i), sys.frame(sys.parent()))
        }
        if (class(i) == "call" && i[[1]] == "list") {
            lstquote <- c(lstquote, as.list(i)[-1])
        }
        else if (class(i) == "character") {
            for (chr in i) {
                lstquote <- c(lstquote, list(parse(text = chr)[[1]]))
            }
        }
        else stop(paste("[", deparse(substitute(i)), "] Unknown class [",
            class(i), "] or is not a list()", sep = ""))
    }
    return(as.call(lstquote))
   }


#------------------------
reshape_per_pop_for_one_sce <- function(lst_loglike1=lst_loglike,
                                        namesimu=paste("simu", 1:5, sep=''),
                                        selected_pops=explicit_pops,
                                        type_of_column="pop",
                                        nby=5){


   # filter lst_loglike to trash away the failed (i.e. non-complete) simus:
   # detection according to the number of rows...
   dd                <- table(unlist(lapply(lst_loglike1, nrow)))
   namesimu          <- names(lst_loglike1)

   # subset
   refsimu     <- namesimu[1]
   lst_loglike <- lst_loglike1[ namesimu ]

   # explicit pops??
   pops <- selected_pops
   idx_col <- grep(type_of_column, colnames(lst_loglike[[refsimu]]))


  # check
  #print("check if same numbers of row across the simus")
  #print( lapply(lst_loglike1[ namesimu ], nrow) )


  # first, reshape for pop
  for (i in 1:length(lst_loglike)){
   lst_loglike[[ i ]] <- lst_loglike[[ i ]][1:nby, colnames(lst_loglike[[ i ]]) %in% c("year",paste0(type_of_column,".",pops)) ]

   lst_loglike[[ i ]] <- cbind( reshape(lst_loglike[[ i ]], idvar="year", varying=list(2:ncol(lst_loglike[[ i ]])),
        v.names=type_of_column, direction="long"), a_pop = rep(pops, each=nrow(lst_loglike[[ i ]])) )
  }

  # reshape...
  res <- NULL
  for(pop in pops){  # for each (explicit) pop
     mat.sim1 <- matrix(unlist(lapply(lst_loglike[ namesimu ], function(x){
                       res <- try(x[x$a_pop==pop, type_of_column], silent=TRUE); if(class(res)=="try-error") res <- rep(NA, ncol(lst_loglike[[refsimu]])); res
                       })), nrow=nrow(lst_loglike[[refsimu]][lst_loglike[[refsimu]]$a_pop==pop,]) , byrow=FALSE)
     colnames(mat.sim1) <- c(paste(type_of_column,"_", namesimu , sep=''))



     mat.sim1 <- replace(mat.sim1, is.na(mat.sim1), 0)

     mat.sim1 <- cbind.data.frame(lst_loglike[[refsimu]] [ lst_loglike[[1]]$a_pop==pop, c("year","a_pop") ], mat.sim1)

     if(!is.null(res)) res <- rbind.data.frame(res, mat.sim1) else res <- mat.sim1

   }


   res <- res[!is.na(res$year),]

   # get the median....
   res <- cbind (res,
                 median=apply(res[,-c(1,2)], 1, quantile, probs=0.5),
                 mean= apply(res[,-c(1,2)], 1, mean)
                 )

 return(res)
 }





### 1- calls for reshaping the lst_popdyn1----------------
count <- 0
for (sce in selected_scenarios){
       count <- count+1

        lst_loglike <- get(paste("lst_loglike_agg_weight", selected, sce, sep=''), env=.GlobalEnv)


       # aggregate landings weight PER YEAR
       for (i in 1:length(lst_loglike)){

         library(data.table)
         loglike       <- lst_loglike[[i]] # input
         if(selected=="_met_") loglike <- loglike[loglike$metier==met,]
         loglike$year  <- unlist(lapply(strsplit(as.character(loglike$year.month), split="\\."), function(x) x[1]))
         nm            <- colnames(loglike)
         idx.col       <- grep(paste0(type_of_column,'.'), nm) # 40: DEBUG
         DT            <- data.table(loglike)
         eq1           <- c.listquote( paste ("sum(",nm[idx.col],",na.rm=TRUE)",sep="") )
         loglike.agg   <- DT[,eval(eq1),by=list(year)]
         loglike.agg   <- data.frame( loglike.agg)
         colnames(loglike.agg) <- c("year", paste(paste0(type_of_column,'.'), selected_pops, sep=''))
         loglike.agg   <- loglike.agg[order(loglike.agg$year),] # order
         lst_loglike[[i]] <- loglike.agg # output
       }

       # keep complete simu i.e. 5 years
       lst_loglike <- lst_loglike [ names(lst_loglike) [lapply(lst_loglike, nrow)>=nby] ]

       loglike_reshaped <- reshape_per_pop_for_one_sce(
                                   lst_loglike1=lst_loglike,
                                   namesimu=general$namesimu[[sce]],
                                   selected_pops=selected_pops,
                                   type_of_column=type_of_column,
                                   nby=nby)
       assign(paste("loglike_", sce, sep=''), loglike_reshaped)
       }



 ### the code for the plot
 all_sces_first_y  <- data.frame(NULL)
 all_sces_last_y   <- data.frame(NULL)
 count    <- 0
 for (sce in selected_scenarios){
   count <- count+1

   loglike <- get(paste("loglike_", sce, sep=''))


   loglike_last_tstep   <- loglike[loglike$year %in%  lasty ,]
   if(firsty!="") loglike_first_tstep  <- loglike[loglike$year %in%  firsty ,]
   pop_names            <-  read.table(file.path(general$main.path.ibm, paste("pop_names_", general$namefolderinput, ".txt", sep='')), header=TRUE)
   if(count==1) group1               <-  as.character(pop_names[ pop_names[,1] %in%   group1 ,2])


   loglike_last_tstep$a_pop          <- factor(loglike_last_tstep$a_pop)
   levels(loglike_last_tstep$a_pop)  <- pop_names[ pop_names[,1] %in%   levels(loglike_last_tstep$a_pop) ,2]
   if(firsty!="") loglike_first_tstep$a_pop         <- factor(loglike_first_tstep$a_pop)
   if(firsty!="") levels(loglike_first_tstep$a_pop) <- pop_names[ pop_names[,1] %in%   levels(loglike_first_tstep$a_pop) ,2]

   if(firsty!="") if(count==1)  all_sces_first_y <- cbind.data.frame(a_pop=as.character(loglike_first_tstep[,"a_pop"]))
   if(firsty!="") all_sces_first_y <- cbind.data.frame(all_sces_first_y, loglike_first_tstep[,"mean"])
   if(firsty!="") colnames(all_sces_first_y)[ncol(all_sces_first_y)] <- scenarios_names[count]

   if(count==1)  all_sces_last_y <- cbind.data.frame(a_pop=as.character(loglike_last_tstep[,"a_pop"]))
   all_sces_last_y <- cbind.data.frame(all_sces_last_y, loglike_last_tstep[,"mean"])
   colnames(all_sces_last_y)[ncol(all_sces_last_y)] <- scenarios_names[count]
  } # end sce



  

    if(black_and_white){
      # split into two groups...
      if(firsty!="") levels(all_sces_first_y$a_pop) [levels(all_sces_first_y$a_pop) %in% group1] <- "GROUP1"
      if(firsty!="") levels(all_sces_first_y$a_pop) [!levels(all_sces_first_y$a_pop) %in% c("GROUP1",group1)] <- "GROUP2"

      levels(all_sces_last_y$a_pop) [levels(all_sces_last_y$a_pop) %in% group1] <- "GROUP1"
      levels(all_sces_last_y$a_pop) [!levels(all_sces_last_y$a_pop) %in% c("GROUP1",group1)] <- "GROUP2"

      if(firsty!="") all_sces_first_y <- aggregate(all_sces_first_y[,-1], list(all_sces_first_y[,1]), sum)
      if(firsty!="") colnames(all_sces_first_y)[1] <- "a_pop"
      if(firsty!="") all_sces_last_y <- aggregate(all_sces_last_y[,-1], list(all_sces_last_y[,1]), sum)
      if(firsty!="") colnames(all_sces_last_y)[1]  <- "a_pop"

      # black and white version
      some_colors <- c(grey(0.2),grey(0.5),grey(1))
      the_density <- rep(500, length(some_colors))
    } else{

      # reorder stocks
      if(firsty!="") all_sces_first_y$a_pop <- factor(all_sces_first_y$a_pop)
    }


   #some_colors <- c("#a6cee3","#1f78b4","red","#b2df8a","green","#33a02c", "#fb9a99",grey(0.5),"#fdbf6f","#ff7f00","#cab2d6","#6a3d9a","#ffff99","#b15928", "black")
   #library(RColorBrewer)
   #qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
   #col_vector <- unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))                 
   some_colors <-  c('#7FC97F','#BEAED4','#FDC086','#FFFF99','#386CB0','#F0027F','#BF5B17','#666666','#1B9E77','#D95F02','#7570B3',
                     '#E7298A','#66A61E','#E6AB02','#A6761D','#666666','#A6CEE3','#1F78B4','#B2DF8A','#33A02C','#FB9A99','#E31A1C',
                     '#FDBF6F','#FF7F00','#CAB2D6','#6A3D9A','#FFFF99','#B15928','#FBB4AE','#B3CDE3','#CCEBC5','#DECBE4','#FED9A6',
                     '#FFFFCC','#E5D8BD','#FDDAEC','#F2F2F2','#B3E2CD','#FDCDAC','#CBD5E8','#F4CAE4','#E6F5C9','#FFF2AE','#F1E2CC',
                     '#CCCCCC','#E41A1C','#377EB8','#4DAF4A','#984EA3','#FF7F00','#FFFF33','#A65628','#F781BF','#999999','#66C2A5',
                     '#FC8D62','#8DA0CB','#E78AC3','#A6D854','#FFD92F','#E5C494','#B3B3B3','#8DD3C7','#FFFFB3','#BEBADA','#FB8072',
                     '#80B1D3','#FDB462','#B3DE69','#FCCDE5','#D9D9D9','#BC80BD','#CCEBC5','#FFED6F')                
   the_density <- rep(500, length(some_colors))
 


   ##-------A PLOT-----------
    graphics.off()
   if(type_of_column=="pop") namefileplot <- paste("landings_per_stock_per_scenario", selected, sep='')
   if(type_of_column=="disc") namefileplot <- paste("discards_per_stock_per_scenario", selected, sep='')

    tiff(file=file.path(general$main.path, general$namefolderinput, paste(namefileplot, ".tiff", sep="")),
                                  width = a_width, height = a_height,   compression="lzw",
                                   units = "px", pointsize = 12,  res=300)
   if(firsty!="") par(mfrow=c(1,2)) 
   par(mar=c(7,3,2,2))
   par(oma=c(3,2,1,1))


   if(firsty!="") rownames(all_sces_first_y) <- all_sces_first_y[,1]
   rownames(all_sces_last_y) <- all_sces_last_y[,1]

   plot_leg <- TRUE
   if(firsty!="") mp_first_y <-  barplot(as.matrix(all_sces_first_y[,-1])/1e6, las=2,  ylim=ylims, xlab="", ylab="",
                          col =some_colors , density=the_density, legend=plot_leg, axes = FALSE,axisnames = FALSE,
                         args.legend = list(x = "topright", bty = "n", ncol=7, cex=0.9))
   if(firsty!="") text(mp_first_y, par("usr")[3], labels = colnames(all_sces_first_y[-1]), srt = 45, adj = 1, xpd = TRUE, cex = 1)
   if(firsty!="") axis(2, las=2)
   if(firsty!="") title ("First year", adj=0)

   
   if(firsty!="") plot_leg <- FALSE
    mp_last_y <-  barplot(as.matrix(all_sces_last_y[,-1])/1e6, las=2, , ylim=ylims, xlab="", ylab="",
                         col =some_colors , density=the_density,  legend=plot_leg, axes = FALSE,axisnames = FALSE,
                        args.legend = list(x = "topright", bty = "n", ncol=7))
   text(mp_last_y, par("usr")[3], labels = colnames(all_sces_last_y[-1]), srt = 45, adj = 1, xpd = TRUE, cex = 1)
   
   mtext("Scenario", 1, line=0, cex=1.5, outer=TRUE)
   if(type_of_column=="pop") mtext(side=2, "Annual landings [*000 tons]", line=0, cex=1., outer=TRUE)
   if(type_of_column=="disc") mtext(side=2, "Annual discards [*000 tons]", line=0, cex=1., outer=TRUE)
   axis(2, las=2)
   title ("Last year", adj=0)

   mtext("Scenario", 1, line=0, cex=1.5, outer=TRUE)
   if(type_of_column=="pop") mtext(side=2,"Annual landings [*000 tons]",line=0, cex=1., outer=TRUE)
   if(type_of_column=="disc") mtext(side=2,"Annual discards [*000 tons]",line=0, cex=1., outer=TRUE)

   dev.off()


return()
}





if(TRUE){
   # GENERAL SETTINGS
   general <- list()
   
   general$case_study <- "BalticSea" #change name according to application (e.g., myfish)
   
   if(.Platform$OS.type == "unix") {}
   
   general$main.path         <- file.path("~","DISPLACE_outputs")                                                                                                   
   general$main.path.igraph  <- file.path("~","DISPLACE_input_raw", "igraph")
   general$main.path.param   <- file.path("~",paste("DISPLACE_input_",general$case_study, sep=""))
   general$main.path.ibm     <- file.path("~",paste("DISPLACE_input_", general$case_study, sep='')) 
   # do not forget to install the R packages on the qrsh interactive node linux platform, i.e. R > install.packages("data.table"), etc.
   # (and possibly kill the current jobs on HPC with the command qselect -u $USER | xargs qdel)
   # submit the shell to HPC with the command qsub ./IBM_processoutput_plots_for_loglike.sh
   
   if(.Platform$OS.type == "windows") {
      #general$main.path         <- file.path("C:","Users","mruf","Documents","PHD_projects","Proj_3","DISPLACE_outputs")  
      general$main.path         <- file.path("D:","PhD","Project III","Results","DISPLACE","DISPLACE_outputs")     
      general$main.path.igraph  <- file.path("C:","Users","mruf","Documents","PHD_projects","Proj_3",paste("DISPLACE_input_",general$case_study, sep=""), "graphsspe")
      general$main.path.param   <- file.path("C:","Users","mruf","Documents","PHD_projects","Proj_3",paste("DISPLACE_input_gis_",general$case_study, sep=""))
      general$main.path.ibm     <- file.path("C:","Users","mruf","Documents","PHD_projects","Proj_3", paste("DISPLACE_input_", general$case_study, sep='')) 
   }
   
   if(general$case_study=="BalticSea"){
      general$igraph            <- 100
      general$a.year            <- "2016"
      general$a.country         <- c("DEU", "DNK", "EST", "FIN", "LTU", "LVA", "POL", "SWE")
      general$nbpops            <- 37  
      general$nbszgroup         <- 14
      general$namefolderinput   <- "BalticSea"
      general$use_sqlite        <- FALSE
      
      
      general$namefolderoutput  <- c( "scebaselinenoclosure",
                                      "scebaseline",
                                      "scenbcpcouplingnoclosure",
                                      "scenbcpcoupling",
                                      "scenbcpcouplingspw",
                                      "scenbcpcouplingrec"
      ) 
      
      
      general$namesimu           <- list( "scebaselinenoclosure"          =   paste("simu", c(1:50), sep=''), 
                                          "scebaseline"       	           =   paste("simu", c(1:50), sep=''),
                                          "scenbcpcouplingnoclosure"   	 =   paste("simu", c(1:50), sep=''), 
                                          "scenbcpcoupling"   	           =   paste("simu", c(1:50), sep=''), 
                                          "scenbcpcouplingspw"	           =   paste("simu", c(1:50), sep=''), 
                                          "scenbcpcouplingrec"	           =   paste("simu", c(1:50), sep='')
                                          
      ) 
      
      
      the_scenarios1 <-  c("Baseline without closure", 
                           "Baseline", 
                           "DISPLACE-LGNB without closure", 
                           "DISPLACE-LGNB with closure",
                           "Spawning closure", 
                           "Nursery closures"
      )
      
   }
   
   
} # end FALSE

#source(file.path("C:","Users","fbas","Documents","GitHub","DISPLACE_input_gis_BalticSea","DISPLACE_R_outputs_ForBalticSea","loadAggLoglikeFiles.R"))
source(file.path("C:","Users","mruf","Documents","PHD_projects","Proj_3","DISPLACE_input_gis_BalticSea","DISPLACE_R_outputs_ForBalticSea","loadAggLoglikeFiles.R"))

loadLoglikeFiles(general=general, use_port_info=FALSE) 

implicit_pops <- c(0, 3, 4, 5, 6, 7, 8, 9, 10, 14, 15, 16, 17, 18, 19, 20, 21, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 36)
explicit_pops <- c(0:36)[-(implicit_pops+1)] 
 
 
  #selected_vessels_set1   <- all_vids
  #   selected_vessels_set2  <-  c(all_vids[grep("GNS",all_vids)],  all_vids[grep("GTR",all_vids)], all_vids[grep("GND",all_vids)])
  #   selected_vessels_set3  <-  all_vids[!all_vids %in% selected_vessels_set2]
  

# landings _selected_set1_
barplotTotLandingsPerSce (general=general,
                                   type_of_column="pop",
                                    selected="_selected_set1_",
                                    selected_pops=2,
                                    group1= 2,
                                     selected_scenarios= c(
                                        #"scebaselinenoclosure",
                                        #"scebaseline",
                                        "scenbcpcouplingnoclosure",
                                        "scenbcpcoupling",
                                        "scenbcpcouplingspw",
                                        "scenbcpcouplingrec"
                                     ),
                                    scenarios_names=c(
                                       "No closure", 
                                       "Standard closure", 
                                       "Alternative Spawning closure", 
                                       "Nursery closure"
                                    ) ,
                                    firsty="", lasty="2020",
                                    a_width=3500, a_height=2000, 
                          black_and_white = FALSE)  # ylims in thousands tons

# discards  _selected_set1_
barplotTotLandingsPerSce (general=general,
                                   type_of_column="disc",
                                    selected="_selected_set1_",
                                     selected_pops=2,
                                    group1= 2,
                          selected_scenarios= c(
                             "scebaselinenoclosure",
                             "scebaseline",
                             "scenbcpcouplingnoclosure",
                             "scenbcpcoupling",
                             "scenbcpcouplingspw",
                             "scenbcpcouplingrec"
                          ),
                          scenarios_names=c(
                             "Baseline without closure", 
                             "Baseline", 
                             "DISPLACE-LGNB without closure", 
                             "DISPLACE-LGNB with closure",
                             "Spawning closure", 
                             "Nursery closures"
                          ) ,
                                    nby=5, firsty="", lasty="2020",
                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,100))  # ylims in thousands tons





# landings _selected_set2_
barplotTotLandingsPerSce (general=general,
                                    type_of_column="pop",
                                     selected="_selected_set2_",
                                     selected_pops=2,
                                    group1= 2,
                          selected_scenarios= c(
                             "scebaselinenoclosure",
                             "scebaseline",
                             "scenbcpcouplingnoclosure",
                             "scenbcpcoupling",
                             "scenbcpcouplingspw",
                             "scenbcpcouplingrec"
                          ),
                          scenarios_names=c(
                             "Baseline without closure", 
                             "Baseline", 
                             "DISPLACE-LGNB without closure", 
                             "DISPLACE-LGNB with closure",
                             "Spawning closure", 
                             "Nursery closures"
                          ) ,
                                    nby=5, firsty="", lasty="2020",
                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,40))  # ylims in thousands tons
                                    

# discards  _selected_set2_
barplotTotLandingsPerSce (general=general,
                                   type_of_column="disc",
                                    selected="_selected_set2_",
                                      selected_pops=2,
                                    group1= 2,
                          selected_scenarios= c(
                             "scebaselinenoclosure",
                             "scebaseline",
                             "scenbcpcouplingnoclosure",
                             "scenbcpcoupling",
                             "scenbcpcouplingspw",
                             "scenbcpcouplingrec"
                          ),
                          scenarios_names=c(
                             "Baseline without closure", 
                             "Baseline", 
                             "DISPLACE-LGNB without closure", 
                             "DISPLACE-LGNB with closure",
                             "Spawning closure", 
                             "Nursery closures"
                          ),
                                    nby=5, firsty="", lasty="2020",
                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,40))  # ylims in thousands tons
                                    
# landings _selected_set3_
barplotTotLandingsPerSce (general=general,
                                    type_of_column="pop",
                                     selected="_selected_set3_",
                                     selected_pops=2,
                                    group1= 2,
                          selected_scenarios= c(
                             "scebaselinenoclosure",
                             "scebaseline",
                             "scenbcpcouplingnoclosure",
                             "scenbcpcoupling",
                             "scenbcpcouplingspw",
                             "scenbcpcouplingrec"
                          ),
                          scenarios_names=c(
                             "Baseline without closure", 
                             "Baseline", 
                             "DISPLACE-LGNB without closure", 
                             "DISPLACE-LGNB with closure",
                             "Spawning closure", 
                             "Nursery closures"
                          ) ,
                                    nby=5, firsty="", lasty="2020",
                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,250))  # ylims in thousands tons
                                    


# discards  _selected_set3_
barplotTotLandingsPerSce (general=general,
                                   type_of_column="disc",
                                    selected="_selected_set3_",
                                      selected_pops=2,
                                    group1= 2,
                          selected_scenarios= c(
                             "scebaselinenoclosure",
                             "scebaseline",
                             "scenbcpcouplingnoclosure",
                             "scenbcpcoupling",
                             "scenbcpcouplingspw",
                             "scenbcpcouplingrec"
                          ),
                          scenarios_names=c(
                             "Baseline without closure", 
                             "Baseline", 
                             "DISPLACE-LGNB without closure", 
                             "DISPLACE-LGNB with closure",
                             "Spawning closure", 
                             "Nursery closures"
                          ) ,
                                    nby=5, firsty="", lasty="2020",
                                    a_width=3500, a_height=2000, black_and_white = FALSE, ylims = c(0,100))  # ylims in thousands tons
