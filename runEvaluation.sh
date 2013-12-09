export COMMON_VM_ARGS="-ea
-Xbootclasspath/a:/Users/Michael/.m2/repository/nl/cwi/jvmbmon/jvmbmon-native/0.0.1/jvmbmon-native-0.0.1.jar
-agentpath:/Users/Michael/Development/Data-Driven-Relations/libjvmbmon.dylib
-javaagent:/Users/Michael/.m2/repository/com/google/memory-measurer/1.0-SNAPSHOT/memory-measurer-1.0-SNAPSHOT.jar
" # -Djava.util.logging.config.file=logging.properties

export RESULT_DIR=`cd ~/Research/orpheus-results && pwd`
export TRACER_DIR=`cd ~/Development/rascal-devel/tracr && pwd`

function executeAnyBenchmark() {
	local benchmark_name=$2

	if [[ -z "$3" ]]; then 
		local heapSize="4096m"
	else 
		local heapSize="$3"
	fi;

	local vm_memory_args="-Xmx"$heapSize

	local DIR_A=$RESULT_DIR/$benchmark_name"_A"$vm_memory_args
	#echo "$DIR_A"
	local DIR_B=$RESULT_DIR/$benchmark_name"_B"$vm_memory_args
	#echo "$DIR_B"
	local DIR_AB=$RESULT_DIR/"_"$benchmark_name$vm_memory_args
	#echo "$DIR_AB"

	local TEST_RUNNER="org.eclipse.imp.pdb.values.benchmarks.SingleJUnitTestRunner"
	#local TEST_RUNNER="org.junit.runner.JUnitCore"


	##
	# Execute Tests/Benchmarks
	###
	if test "$1" == "JUnit"; then 
		java $COMMON_VM_ARGS $vm_memory_args -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name
	else
		java $COMMON_VM_ARGS $vm_memory_args -DbenchmarkName=$benchmark_name -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark
	fi;	
	mkdir -p $DIR_A
	mv target/*.bin* $DIR_A
	#
	if [[ $1 == "JUnit" ]]; then 
		java $COMMON_VM_ARGS $vm_memory_args -DsharingEnabled -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name
	else
		java $COMMON_VM_ARGS $vm_memory_args -DbenchmarkName=$benchmark_name -DsharingEnabled -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark
	fi;	
	mkdir -p $DIR_B 
	mv target/*.bin* $DIR_B


	##
	# Log Postprocessing with Tracr
	###
	(cd $TRACER_DIR && sbt "run `echo $DIR_A`")
	mv $TRACER_DIR/*.dat $DIR_A
	#	
	(cd $TRACER_DIR && sbt "run `echo $DIR_B` sharingEnabled")
	mv $TRACER_DIR/*.dat $DIR_B


	##
	# Evaluation and Graph Plotting with R
	###
	mkdir -p $DIR_AB
	cp $DIR_A/*.dat $DIR_AB
	cp $DIR_B/*.dat $DIR_AB
	cp $DIR_B/_hashAndCacheStatistic.bin.txt $DIR_AB
	#
	(cd $DIR_AB && Rscript $TRACER_DIR/doPlot.r)


	##
	# Misc.
	###
	echo $benchmark_name > _benchmarkName.bin.txt
}

function executeRascalShellBenchmark() {
	echo "Executing $1 $2"
	time executeAnyBenchmark "RascalShell" $1 $2	
}

function executeJUnitBenchmark() {
	echo "Executing $1 $2"
	time executeAnyBenchmark "JUnit" $1 $2	
}

##
# Run the tests.
###

trap "exit" INT
mkdir -p $RESULT_DIR

# executeRascalShellBenchmark "doImportPrelude" "2048m"
# executeRascalShellBenchmark "doImportPrelude" "1024m"
# executeRascalShellBenchmark "doImportPrelude" "0512m"
# executeRascalShellBenchmark "doImportPrelude" "0256m"

# executeRascalShellBenchmark "doExpLang" "2048m"
# executeRascalShellBenchmark "doExpLang" "1792m"
# executeRascalShellBenchmark "doExpLang" "1536m"

# ## executeRascalShellBenchmark "doM3FromDirectory" "2048m"
# ## executeRascalShellBenchmark "doM3FromDirectory" "1536m"
# ## executeRascalShellBenchmark "doM3FromDirectory" "1024m"

# executeRascalShellBenchmark "doTypeCheckParserGenerator" "3072m"
# executeRascalShellBenchmark "doTypeCheckParserGenerator" "2816m"
# executeRascalShellBenchmark "doTypeCheckParserGenerator" "2560m"
# executeRascalShellBenchmark "doTypeCheckParserGenerator" "2048m"
# # executeRascalShellBenchmark "doTypeCheckParserGenerator" "1792m"
# # executeRascalShellBenchmark "doTypeCheckParserGenerator" "1536m"

# executeRascalShellBenchmark "MOD17_EVALEXP_05"
# executeRascalShellBenchmark "MOD17_EVALSYM_05"
# executeRascalShellBenchmark "MOD17_EVALTREE_05"
# #
# executeRascalShellBenchmark "MOD17_EVALEXP_10"
# executeRascalShellBenchmark "MOD17_EVALSYM_10"
# executeRascalShellBenchmark "MOD17_EVALTREE_10"
# #
# executeRascalShellBenchmark "MOD17_EVALEXP_15"
# executeRascalShellBenchmark "MOD17_EVALSYM_15"
# executeRascalShellBenchmark "MOD17_EVALTREE_15"
#
# executeRascalShellBenchmark "MOD17_EVALEXP_20"
# executeRascalShellBenchmark "MOD17_EVALSYM_20"
# executeRascalShellBenchmark "MOD17_EVALTREE_20"
#
# executeRascalShellBenchmark "MOD17_EVALEXP_25" "8192m"
# executeRascalShellBenchmark "MOD17_EVALSYM_25" "8192m"
# executeRascalShellBenchmark "MOD17_EVALTREE_25" "8192m"
#
# executeRascalShellBenchmark "MOD17_EVALEXP_30" "8192m"
# executeRascalShellBenchmark "MOD17_EVALSYM_30" "8192m"
# executeRascalShellBenchmark "MOD17_EVALTREE_30" "8192m"

# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" # "3072m" "2560m" "2048m" "1536m" "1024m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "3072m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "2560m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "2048m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "1536m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "1024m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" # "3072m" "2560m" "2048m" "1536m" "1024m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "3072m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "2560m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "2048m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "1536m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "1024m"

# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" # "3072m" "2560m" "2048m" "1536m" "1024m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "3072m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "2560m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "2048m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "1536m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "1024m"
executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" # "3072m" "2560m" "2048m" "1536m" "1024m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "3072m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "2560m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "2048m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "1536m"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "1024m"

# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJHotDraw52"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJWAM16FullAndreas"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureEclipse202a"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closurejdk14v2"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJDK140AWT"

# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJHotDraw52"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJWAM16FullAndreas"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarEclipse202a"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarjdk14v2"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJDK140AWT"

# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_5_000"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_10_000"
# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_15_000"

# executeJUnitBenchmark "org.eclipse.imp.pdb.values.benchmarks.ModelAggregationBenchmark"