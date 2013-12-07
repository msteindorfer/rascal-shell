export COMMON_VM_ARGS="-ea
-Xbootclasspath/a:/Users/Michael/.m2/repository/nl/cwi/jvmbmon/jvmbmon-native/0.0.1/jvmbmon-native-0.0.1.jar
-agentpath:/Users/Michael/Development/Data-Driven-Relations/libjvmbmon.dylib
-javaagent:/Users/Michael/.m2/repository/com/google/memory-measurer/1.0-SNAPSHOT/memory-measurer-1.0-SNAPSHOT.jar
" # -Djava.util.logging.config.file=logging.properties

export RESULT_DIR=`cd ~/Research/orpheus-results && pwd`
export TRACER_DIR=`cd ~/Development/rascal-devel/tracr && pwd`

export SHARING_ENABLED="-DsharingEnabled"
export MEMORY_VM_ARGS="-Xmx256m"
#
if [ -n $SHARING_ENABLED ]; then 
	export RUN_PREFIX="_B"
else 
	export RUN_PREFIX="_A"
fi;
#

function executeBenchmark() {
	local benchmark_name=$1

	if [ -o $2 ]; then 
		local heapSize="4g"
	else 
		local heapSize="$2"
	fi;

	local vm_memory_args="-Xmx"$heapSize

	local DIR_A=$RESULT_DIR/$benchmark_name"_A"$vm_memory_args
	#echo "$DIR_A"
	local DIR_B=$RESULT_DIR/$benchmark_name"_B"$vm_memory_args
	#echo "$DIR_B"

	java $COMMON_VM_ARGS $vm_memory_args -DbenchmarkName=$benchmark_name -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark
	mkdir $DIR_A
	mv target/*.bin* $DIR_A
	#
	java $COMMON_VM_ARGS $vm_memory_args -DbenchmarkName=$benchmark_name -DsharingEnabled -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark
	mkdir $DIR_B 
	mv target/*.bin* $DIR_B
}

function executeJUnitBenchmarks() {
	local benchmark_name=$1

	if [ -o $2 ]; then 
		local heapSize="4g"
	else 
		local heapSize="$2"
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

	# java $COMMON_VM_ARGS $vm_memory_args -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name
	# mkdir $DIR_A
	# mv target/*.bin* $DIR_A
	# #
	(cd $TRACER_DIR && sbt "run `echo $DIR_A`")
	mv $TRACER_DIR/*.dat $DIR_A
	#
	# java $COMMON_VM_ARGS $vm_memory_args -DsharingEnabled -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name
	# mkdir $DIR_B 
	# mv target/*.bin* $DIR_B
	#
	(cd $TRACER_DIR && sbt "run `echo $DIR_B` sharingEnabled")
	mv $TRACER_DIR/*.dat $DIR_B

	mkdir $DIR_AB
	cp $DIR_A/*.dat $DIR_AB
	cp $DIR_B/*.dat $DIR_AB

	(cd $DIR_AB && Rscript $TRACER_DIR/doPlot.r)
}

##
# Run the tests.
###

trap "exit" INT

# executeBenchmark "doImportPrelude" "2048m"
# executeBenchmark "doImportPrelude" "1024m"
# executeBenchmark "doImportPrelude" "0512m"
# executeBenchmark "doImportPrelude" "0256m"

# executeBenchmark "doExpLang" "2048m"
# executeBenchmark "doExpLang" "1792m"
# executeBenchmark "doExpLang" "1536m"

## executeBenchmark "doM3FromDirectory" "2048m"
## executeBenchmark "doM3FromDirectory" "1536m"
## executeBenchmark "doM3FromDirectory" "1024m"

# # TODO
# executeBenchmark "doTypeCheckParserGenerator" "2048m"
# executeBenchmark "doTypeCheckParserGenerator" "1792m"
# executeBenchmark "doTypeCheckParserGenerator" "1536m"

# # TODO
# executeBenchmark "MOD17_EVALEXP_10"
# executeBenchmark "MOD17_EVALSYM_10"
# executeBenchmark "MOD17_EVALTREE_10"

# # TODO
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElements"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations"

# TODO
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElements" # "3072m" "2560m" "2048m" "1536m" "1024"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations"

# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.ModelAggregationBenchmark#timeUnionRelations"

# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJHotDraw52"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJWAM16FullAndreas"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureEclipse202a"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closurejdk14v2"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureJDK140AWT"

# # TODO
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJHotDraw52"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJWAM16FullAndreas"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarEclipse202a"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarjdk14v2"
# executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJDK140AWT"

executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_5_000"
executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_10_000"
executeJUnitBenchmarks "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_15_000"
