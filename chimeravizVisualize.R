source("http://bioconductor.org/biocLite.R")
chooseBioCmirror()

biocLite("Rsubread")


# sudo apt install -y aptitude libcurl4-openssl-dev libxml2-dev
install.packages("RCurl", dependencies = T)
biocLite("chimeraviz")

library(chimeraviz)

length(fusions)
soapfuse833ke <- system.file("extdata", "soapfuse_833ke_final.Fusion.specific.for.genes", package = "chimeraviz")
fusions <- importSoapfuse(soapfuse833ke, "hg38", 10)
plotCircle(fusions)


defuse833ke <- system.file("extdata", "defuse_833ke_results.filtered.tsv", package = "chimeraviz")
fusions <- importDefuse(defuse833ke, "hg19")

fusion <- getFusionById(fusions, 5267)

edbSqliteFile <- system.file(
  "extdata",
  "Homo_sapiens.GRCh37.74.sqlite",
  package = "chimeraviz"
)
edb <- ensembldb::EnsDb(edbSqliteFile)

print(edbSqliteFile)
fusion5267and11759reads <- system.file(
  "extdata",
  "fusion5267and11759reads.bam",
  package = "chimeraviz"
)
plotFusion(
  fusion = fusion,
  bamfile = fusion5267and11759reads,
  edb = edb,
  nonUCSC = TRUE
)

??chimeraviz



p26 <- read.table("./IonXpress_026.star_fusion/整理.tsv", header = T, as.is = T)
p26.fusions <- importDefuse("./IonXpress_026.star_fusion/整理.tsv", "hg19")
p26.fusions <- importStarfusion("./IonXpress_026.star_fusion/整理.tsv", "hg19")
p26.fusions <- importStarfusion("./IonXpress_026.star_fusion/star-fusion.fusion_predictions.tsv", "hg19")
plotCircle(p26.fusions)
# 红色条带-染色体内融合，蓝色条带-染色体间融合。

# 单独可视化某个融合事件
fusion <- getFusionByGeneName(p26.fusions, "EML4")
plotFusion(fusion = p26.fusions[[1]]
           , bamfile = "IonXpress_026.star_fusion/std.STAR.sorted.bam"
           , reduceTranscripts = TRUE
           , edb = NULL
           )


# https://bioconductor.org/packages/release/bioc/vignettes/chimeraviz/inst/doc/chimeraviz-vignette.html#introduction
