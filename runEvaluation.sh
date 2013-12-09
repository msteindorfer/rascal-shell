export COMMON_VM_ARGS="-ea
-Xbootclasspath/a:/Users/Michael/.m2/repository/nl/cwi/jvmbmon/jvmbmon-native/0.0.1/jvmbmon-native-0.0.1.jar
-agentpath:/Users/Michael/Development/Data-Driven-Relations/libjvmbmon.dylib
-javaagent:/Users/Michael/.m2/repository/com/google/memory-measurer/1.0-SNAPSHOT/memory-measurer-1.0-SNAPSHOT.jar
" # -Djava.util.logging.config.file=logging.properties

export RESULT_DIR=`cd ~/Research/orpheus-results && pwd`
export TRACER_DIR=`cd ~/Development/rascal-devel/tracr && pwd`

function executeAnyBenchmark() {
	local benchmark_short_name=$2
	local benchmark_name=$3

	if [[ -z "$4" ]]; then 
		local heapSize="4096m"
	else 
		local heapSize="$4"
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
	echo $benchmark_short_name > _benchmarkShortName.bin.txt
	echo $benchmark_name > _benchmarkName.bin.txt
	echo $heapSize > _heapSize.bin.txt
}

function executeRascalShellBenchmark() {
	echo "Executing $1 $2 $3"
	time executeAnyBenchmark "RascalShell" $1 $2 $3
}

function executeJUnitBenchmark() {
	echo "Executing $1 $2 $3"
	time executeAnyBenchmark "JUnit" $1 $2 $3
}

##
# Run the tests.
###

trap "exit" INT
mkdir -p $RESULT_DIR

executeRascalShellBenchmark "A1" "doImportPrelude" "2048m"
executeRascalShellBenchmark "A2" "doImportPrelude" "1024m"
executeRascalShellBenchmark "A3" "doImportPrelude" "0512m"
executeRascalShellBenchmark "A4" "doImportPrelude" "0256m"

executeRascalShellBenchmark "B1" "doExpLang" "2048m"
executeRascalShellBenchmark "B2" "doExpLang" "1792m"
executeRascalShellBenchmark "B3" "doExpLang" "1536m"

# executeRascalShellBenchmark "doM3FromDirectory" "2048m"
# executeRascalShellBenchmark "doM3FromDirectory" "1536m"
# executeRascalShellBenchmark "doM3FromDirectory" "1024m"

executeRascalShellBenchmark "C1" "doTypeCheckParserGenerator" "3072m"
executeRascalShellBenchmark "C2" "doTypeCheckParserGenerator" "2816m"
executeRascalShellBenchmark "C3" "doTypeCheckParserGenerator" "2560m"
executeRascalShellBenchmark "C4" "doTypeCheckParserGenerator" "2048m"
executeRascalShellBenchmark "C5" "doTypeCheckParserGenerator" "1792m"
executeRascalShellBenchmark "C6" "doTypeCheckParserGenerator" "1536m"

executeRascalShellBenchmark "D1" "MOD17_EVALEXP_05"
executeRascalShellBenchmark "E1" "MOD17_EVALSYM_05"
executeRascalShellBenchmark "F1" "MOD17_EVALTREE_05"
#
executeRascalShellBenchmark "D2" "MOD17_EVALEXP_10"
executeRascalShellBenchmark "E2" "MOD17_EVALSYM_10"
executeRascalShellBenchmark "F2" "MOD17_EVALTREE_10"
#
executeRascalShellBenchmark "D3" "MOD17_EVALEXP_15"
executeRascalShellBenchmark "E3" "MOD17_EVALSYM_15"
executeRascalShellBenchmark "F3" "MOD17_EVALTREE_15"
#
executeRascalShellBenchmark "D4" "MOD17_EVALEXP_20"
executeRascalShellBenchmark "E4" "MOD17_EVALSYM_20"
executeRascalShellBenchmark "F4" "MOD17_EVALTREE_20"
#
executeRascalShellBenchmark "D5" "MOD17_EVALEXP_25" "8192m"
executeRascalShellBenchmark "E5" "MOD17_EVALSYM_25" "8192m"
executeRascalShellBenchmark "F5" "MOD17_EVALTREE_25" "8192m"
#
executeRascalShellBenchmark "D6" "MOD17_EVALEXP_30" "8192m"
executeRascalShellBenchmark "E6" "MOD17_EVALSYM_30" "8192m"
executeRascalShellBenchmark "F6" "MOD17_EVALTREE_30" "8192m"

executeJUnitBenchmark "G1" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements"
executeJUnitBenchmark "H1" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" # "3072m" "2560m" "2048m" "1536m" "1024m"
executeJUnitBenchmark "H2" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "3072m"
executeJUnitBenchmark "H3" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "2560m"
executeJUnitBenchmark "H4" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "2048m"
executeJUnitBenchmark "H5" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "1536m"
executeJUnitBenchmark "H6" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements" "1024m"
executeJUnitBenchmark "I1" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" # "3072m" "2560m" "2048m" "1536m" "1024m"
executeJUnitBenchmark "I2" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "3072m"
executeJUnitBenchmark "I3" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "2560m"
executeJUnitBenchmark "I4" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "2048m"
executeJUnitBenchmark "I5" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "1536m"
executeJUnitBenchmark "I6" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations" "1024m"

executeJUnitBenchmark "J1" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements"
executeJUnitBenchmark "K1" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" # "3072m" "2560m" "2048m" "1536m" "1024m"
executeJUnitBenchmark "K2" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "3072m"
executeJUnitBenchmark "K3" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "2560m"
executeJUnitBenchmark "K4" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "2048m"
executeJUnitBenchmark "K5" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "1536m"
executeJUnitBenchmark "K6" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" "1024m"
executeJUnitBenchmark "L1" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" # "3072m" "2560m" "2048m" "1536m" "1024m"
executeJUnitBenchmark "L2" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "3072m"
executeJUnitBenchmark "L3" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "2560m"
executeJUnitBenchmark "L4" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "2048m"
executeJUnitBenchmark "L5" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "1536m"
executeJUnitBenchmark "L6" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations" "1024m"

executeJUnitBenchmark "MA" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJHotDraw52"
executeJUnitBenchmark "NA" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJWAM16FullAndreas"
executeJUnitBenchmark "OA" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureEclipse202a"
executeJUnitBenchmark "PA" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closurejdk14v2"
executeJUnitBenchmark "QA" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJDK140AWT"

executeJUnitBenchmark "MB" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJHotDraw52"
executeJUnitBenchmark "NB" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJWAM16FullAndreas"
executeJUnitBenchmark "OB" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarEclipse202a"
executeJUnitBenchmark "PB" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarjdk14v2"
executeJUnitBenchmark "QB" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJDK140AWT"

executeJUnitBenchmark "RA" "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_5_000"
executeJUnitBenchmark "RB" "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_10_000"
executeJUnitBenchmark "RC" "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_15_000"

executeJUnitBenchmark "S1" "org.eclipse.imp.pdb.values.benchmarks.ModelAggregationBenchmark"