configfile: "config/config_hg38.yaml"
configfile: "config/samples.yaml"

rule all:
  input: 
  	expand("results/ichorCNA/{tumor}/{tumor}.cna.seg", tumor=config["samples"]),
  	expand("results/readDepth/{samples}.bin{binSize}.wig", samples=config["samples"], binSize=str(config["binSize"]))

rule read_counter:
	input:
		lambda wildcards: config["samples"][wildcards.samples]
	output:
		"results/readDepth/{samples}.bin{binSize}.wig"		
	params:
		readCounter=config["readCounterScript"],
		binSize=config["binSize"],
		qual="20",
		chrs=config["chrs"]
	resources:
		mem=4
	log:
		"logs/readDepth/{samples}.bin{binSize}.log"
	shell:
		"{params.readCounter} {input} -c {params.chrs} -w {params.binSize} -q {params.qual} > {output} 2> {log}"

rule ichorCNA:
	input:
		tum="results/readDepth/{tumor}.bin" + str(config["binSize"]) + ".wig",
		#norm=lambda wildcards: "results/readDepth/" + config["pairings"][wildcards.tumor] + ".bin" + str(config["binSize"]) + ".wig"
	output:
		#corrDepth="results/ichorCNA/{tumor}/{tumor}.correctedDepth.txt",
		#param="results/ichorCNA/{tumor}/{tumor}.params.txt",
		cna="results/ichorCNA/{tumor}/{tumor}.cna.seg",
		#segTxt="results/ichorCNA/{tumor}/{tumor}.seg.txt",
		#seg="results/ichorCNA/{tumor}/{tumor}.seg",
		#rdata="results/ichorCNA/{tumor}/{tumor}.RData"
	params:
		outDir="results/ichorCNA/{tumor}/",
		rscript=config["ichorCNA_rscript"],
		id="{tumor}",
		ploidy=config["ichorCNA_ploidy"],
		normal=config["ichorCNA_normal"],
		sex=config["ichorCNA_sex"],
		gcwig=config["ichorCNA_gcWig"],
		mapwig=config["ichorCNA_mapWig"],
		repTimeWig=config["ichorCNA_repTimeWig"],
		#normalpanel=config["ichorCNA_normalPanel"], #skip normal panel, not available for 10kb
		estimateNormal=config["ichorCNA_estimateNormal"],
		estimatePloidy=config["ichorCNA_estimatePloidy"],
		estimateClonality=config["ichorCNA_estimateClonality"],
		scStates=config["ichorCNA_scStates"],
		maxCN=config["ichorCNA_maxCN"],
		includeHOMD=config["ichorCNA_includeHOMD"],
		chrs=config["ichorCNA_chrs"],
		chrTrain=config["ichorCNA_chrTrain"],
		genomeBuild=config["ichorCNA_genomeBuild"],
		genomeStyle=config["ichorCNA_genomeStyle"],
		centromere=config["ichorCNA_centromere"],
		fracReadsChrYMale="0.001",
		minMapScore=config["ichorCNA_minMapScore"],
		maxFracGenomeSubclone=config["ichorCNA_maxFracGenomeSubclone"],
		maxFracCNASubclone=config["ichorCNA_maxFracCNASubclone"],
		exons=config["ichorCNA_exons"],
		txnE=config["ichorCNA_txnE"],
		txnStrength=config["ichorCNA_txnStrength"],
		plotFileType=config["ichorCNA_plotFileType"],
		plotYlim=config["ichorCNA_plotYlim"],
		libdir=config["ichorCNA_libdir"]

	log:
		"logs/ichorCNA/{tumor}.log"	
	shell:
		"Rscript {params.rscript} --id {params.id} --libdir {params.libdir} --WIG {input.tum} --gcWig {params.gcwig} --mapWig {params.mapwig} --repTimeWig {params.repTimeWig} --sex {params.sex} --ploidy \"{params.ploidy}\" --normal \"{params.normal}\" --maxCN {params.maxCN} --includeHOMD {params.includeHOMD} --chrs \"{params.chrs}\" --chrTrain \"{params.chrTrain}\" --genomeStyle {params.genomeStyle} --genomeBuild {params.genomeBuild} --estimateNormal {params.estimateNormal} --estimatePloidy {params.estimatePloidy} --estimateScPrevalence {params.estimateClonality} --scStates \"{params.scStates}\" --centromere {params.centromere} --exons.bed {params.exons} --txnE {params.txnE} --txnStrength {params.txnStrength} --minMapScore {params.minMapScore} --fracReadsInChrYForMale {params.fracReadsChrYMale} --maxFracGenomeSubclone {params.maxFracGenomeSubclone} --maxFracCNASubclone {params.maxFracCNASubclone} --plotFileType {params.plotFileType} --plotYLim \"{params.plotYlim}\" --outDir {params.outDir} > {log} 2> {log}"

