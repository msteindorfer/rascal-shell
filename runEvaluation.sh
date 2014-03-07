export COMMON_VM_ARGS="-server
-Xbootclasspath/a:/Users/Michael/.m2/repository/nl/cwi/jvmbmon/jvmbmon-native/0.0.1/jvmbmon-native-0.0.1.jar
-agentpath:/Users/Michael/Development/Data-Driven-Relations/libjvmbmon.dylib
-javaagent:/Users/Michael/.m2/repository/com/google/memory-measurer/1.0-SNAPSHOT/memory-measurer-1.0-SNAPSHOT.jar
-XX:+DisableExplicitGC -XX:+UseParallelOldGC
-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Xloggc:target/gc.log
" 

export RESULT_DIR=`cd ~/Research/orpheus-results && pwd`
export TRACER_DIR=`cd ~/Development/rascal-devel/tracr && pwd`

export MODE=$1

function executeAnyBenchmark() {
	local benchmark_short_name=$2
	local benchmark_name=$3
	local benchmakr_run_nr=$4

	if [[ -z "$5" ]]; then 
		local heapSizeA="4096m"
	else 
		local heapSizeA="$5"
	fi;

	if [[ -z "$6" ]]; then 
		local heapSizeB="$heapSizeA"
	else 
		local heapSizeB="$6"
	fi;

	local vm_memory_argsA="-Xms`echo $heapSizeA` -Xmx`echo $heapSizeA`" 
	local vm_memory_argsB="-Xms`echo $heapSizeB` -Xmx`echo $heapSizeB`" 

	if [[ "$heapSizeA" == "$heapSizeB" ]]; then 
		local heapSizeAB=$heapSizeA
	else 
		local heapSizeAB=$heapSizeA$heapSizeB
	fi;	

	# echo "$heapSizeA $heapSizeB $heapSizeAB"
	# echo "$vm_memory_argsA $vm_memory_argsB"

	local DIR_A=$RESULT_DIR/$benchmark_name"_A"`echo $vm_memory_argsA | tr ' ' '_'`
	# echo "$DIR_A"
	local DIR_A2=$RESULT_DIR/$benchmark_name"_A2"`echo $vm_memory_argsA | tr ' ' '_'`
	# echo "$DIR_A2"
	local DIR_A3=$RESULT_DIR/$benchmark_name"_A3"`echo $vm_memory_argsA | tr ' ' '_'`
	# echo "$DIR_A3"	
	local DIR_B=$RESULT_DIR/$benchmark_name"_B"`echo $vm_memory_argsB | tr ' ' '_'`
	# echo "$DIR_B"
	local DIR_AA=$RESULT_DIR/$benchmark_name"_AA"`echo $vm_memory_argsA | tr ' ' '_'`
	# echo "$DIR_AA"
	local DIR_BB=$RESULT_DIR/$benchmark_name"_BB"`echo $vm_memory_argsB | tr ' ' '_'`
	# echo "$DIR_BB"

	if [[ "$benchmakr_run_nr" == "--" ]]; then 
		local DIR_AB=$RESULT_DIR/"_"$benchmark_name`echo $vm_memory_argsA | tr ' ' '_'``echo $vm_memory_argsB | tr ' ' '_'`
		echo "$DIR_AB"
	else
		local DIR_AB=$RESULT_DIR/"_"$benchmark_name`echo $vm_memory_argsA | tr ' ' '_'``echo $vm_memory_argsB | tr ' ' '_'`/$benchmakr_run_nr
		echo "$DIR_AB"		
	fi;

	local TEST_RUNNER="org.eclipse.imp.pdb.values.benchmarks.SingleJUnitTestRunner"
	#local TEST_RUNNER="org.junit.runner.JUnitCore"


	##
	# Execute Tests/Benchmarks
	###
	if (("$MODE" >= "7"))
	then
		echo "Start A."
		if test "$1" == "JUnit"; then 
			command java $COMMON_VM_ARGS $vm_memory_argsA -DredundancyProfilingEnabled -DXORHashingEnabled -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name 1>target/_stdout.log 2>target/_stderr.log
		else
			command java $COMMON_VM_ARGS $vm_memory_argsA -DbenchmarkName=$benchmark_name -DredundancyProfilingEnabled -DXORHashingEnabled -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark 1>target/_stdout.log 2>target/_stderr.log
		fi;	
		mkdir -p $DIR_A
		mv target/{*.bin*,*.log} $DIR_A
		mv target/_timeBenchmark.txt $DIR_A/_timeBenchmarkA.txt
		echo "Done A."
		#
		echo "Start A2."
		if test "$1" == "JUnit"; then 
			command java $COMMON_VM_ARGS $vm_memory_argsA -DredundancyProfilingEnabled -DorderUnorderedDisabled -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name 1>target/_stdout.log 2>target/_stderr.log
		else
			command java $COMMON_VM_ARGS $vm_memory_argsA -DbenchmarkName=$benchmark_name -DredundancyProfilingEnabled -DorderUnorderedDisabled -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark 1>target/_stdout.log 2>target/_stderr.log
		fi;	
		mkdir -p $DIR_A2
		mv target/{*.bin*,*.log} $DIR_A2
		mv target/_timeBenchmark.txt $DIR_A2/_timeBenchmarkA2.txt
		echo "Done A2."
		#
		echo "Start A3."
		if test "$1" == "JUnit"; then 
			command java $COMMON_VM_ARGS $vm_memory_argsA -DredundancyProfilingEnabled -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name 1>target/_stdout.log 2>target/_stderr.log
		else
			command java $COMMON_VM_ARGS $vm_memory_argsA -DbenchmarkName=$benchmark_name -DredundancyProfilingEnabled -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark 1>target/_stdout.log 2>target/_stderr.log
		fi;	
		mkdir -p $DIR_A3
		mv target/{*.bin*,*.log} $DIR_A3
		mv target/_timeBenchmark.txt $DIR_A3/_timeBenchmarkA3.txt
		echo "Done A3."		
				
		echo "Start B."
		if [[ $1 == "JUnit" ]]; then 
			command java $COMMON_VM_ARGS $vm_memory_argsB -DsharingEnabled -DredundancyProfilingEnabled -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name 1>target/_stdout.log 2>target/_stderr.log
		else
			command java $COMMON_VM_ARGS $vm_memory_argsB -DbenchmarkName=$benchmark_name -DsharingEnabled -DredundancyProfilingEnabled -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark 1>target/_stdout.log 2>target/_stderr.log
		fi;	
		mkdir -p $DIR_B 
		mv target/{*.bin*,*.log} $DIR_B
		mv target/_timeBenchmark.txt $DIR_B/_timeBenchmarkB.txt
		echo "Done B."		
		#
		#
		#
		echo "Start AA."
		if test "$1" == "JUnit"; then 
			command java $COMMON_VM_ARGS $vm_memory_argsA -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name 1>target/_stdout.log 2>target/_stderr.log
		else
			command java $COMMON_VM_ARGS $vm_memory_argsA -DbenchmarkName=$benchmark_name -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark 1>target/_stdout.log 2>target/_stderr.log
		fi;	
		mkdir -p $DIR_AA
		mv target/{*.bin*,*.log} $DIR_AA
		mv target/_timeBenchmark.txt $DIR_AA/_timeBenchmarkAA.txt
		echo "Done AA."		
		#
		echo "Start BB."
		if [[ $1 == "JUnit" ]]; then 
			command java $COMMON_VM_ARGS $vm_memory_argsB -DsharingEnabled -classpath .:target/rascal-shell-0.6.2-SNAPSHOT.jar $TEST_RUNNER $benchmark_name 1>target/_stdout.log 2>target/_stderr.log
		else
			command java $COMMON_VM_ARGS $vm_memory_argsB -DbenchmarkName=$benchmark_name -DsharingEnabled -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark 1>target/_stdout.log 2>target/_stderr.log
		fi;	
		mkdir -p $DIR_BB 
		mv target/{*.bin*,*.log} $DIR_BB
		mv target/_timeBenchmark.txt $DIR_BB/_timeBenchmarkBB.txt
		echo "Done BB."	
	fi


	##
	# Log Postprocessing with Tracr
	###
	if (("$MODE" >= "4"))
	then
		(cd $TRACER_DIR && sbt "run `echo $DIR_A`")
		mv $TRACER_DIR/*.dat $DIR_A
		mv $TRACER_DIR/target/_timeTracr.txt $DIR_A/_timeTracrA.txt
		#	
		(cd $TRACER_DIR && sbt "run `echo $DIR_A2`")
		mv $TRACER_DIR/*.dat $DIR_A2
		mv $TRACER_DIR/target/_timeTracr.txt $DIR_A2/_timeTracrA2.txt
		#	
		(cd $TRACER_DIR && sbt "run `echo $DIR_A3`")
		mv $TRACER_DIR/*.dat $DIR_A3
		mv $TRACER_DIR/target/_timeTracr.txt $DIR_A3/_timeTracrA3.txt
		#			
		(cd $TRACER_DIR && sbt "run `echo $DIR_B` sharingEnabled")
		mv $TRACER_DIR/*.dat $DIR_B
		mv $TRACER_DIR/target/_timeTracr.txt $DIR_B/_timeTracrB.txt
	fi


	##
	# Evaluation and Graph Plotting with R
	###	
	if (("$MODE" >= "1"))
	then
		mkdir -p $DIR_AB
		cp $DIR_A/{*.dat,_time*} $DIR_AB
		cp $DIR_B/{*.dat,_time*} $DIR_AB
		#
		cp $DIR_AA/_time* $DIR_AB
		cp $DIR_BB/_time* $DIR_AB
		#
		cp $DIR_A2/objectCount-nom.dat $DIR_AB/objectCount-nom-without-reordering.dat
		cp $DIR_A2/objectCount-min.dat $DIR_AB/objectCount-min-without-reordering.dat
		cp $DIR_A2/heapSizes-nom.dat $DIR_AB/heapSizes-nom-without-reordering.dat
		cp $DIR_A2/heapSizes-min.dat $DIR_AB/heapSizes-min-without-reordering.dat
		cp $DIR_A2/_time* $DIR_AB		
		#
		cp $DIR_A3/objectCount-nom.dat $DIR_AB/objectCount-nom-with-xor-hashing.dat
		cp $DIR_A3/objectCount-min.dat $DIR_AB/objectCount-min-with-xor-hashing.dat
		cp $DIR_A3/heapSizes-nom.dat $DIR_AB/heapSizes-nom-with-xor-hashing.dat
		cp $DIR_A3/heapSizes-min.dat $DIR_AB/heapSizes-min-with-xor-hashing.dat
		cp $DIR_A3/_time* $DIR_AB		
		#		
		mkdir -p $DIR_AB/logA
		cp $DIR_A/*.log $DIR_AB/logA
		#
		mkdir -p $DIR_AB/logB
		cp $DIR_B/*.log $DIR_AB/logB		
		#
		cp $DIR_B/_hashAndCacheStatistic.bin.txt $DIR_AB
		#
		echo $benchmark_short_name > $DIR_AB/_benchmarkShortName.bin.txt
		echo $benchmark_name > $DIR_AB/_benchmarkName.bin.txt
		echo $heapSizeB > $DIR_AB/_heapSize.bin.txt
		echo $heapSizeA > $DIR_AB/_heapSizeA.bin.txt
		echo $heapSizeB > $DIR_AB/_heapSizeB.bin.txt
		#
		(cd $DIR_AB && Rscript $TRACER_DIR/doPlot.r)
	fi
}

function executeRascalShellBenchmark() {
	echo "Executing $1 $2 $3 $4"
	time executeAnyBenchmark "RascalShell" $1 $2 -- $3 $4
}

function executeJUnitBenchmark() {
	echo "Executing $1 $2 $3 $4"
	time executeAnyBenchmark "JUnit" $1 $2 -- $3 $4
}

##
# Run the tests.
###

trap "exit" INT
mkdir -p $RESULT_DIR

# ##
# # External evaluation (PDB/Rascal)
# ###
executeRascalShellBenchmark "A" "doImportPrelude"
executeRascalShellBenchmark "B" "doExpLang"
executeRascalShellBenchmark "C" "doTypeCheckParserGenerator"

executeRascalShellBenchmark "ME05" "MOD17_EVALEXP_05"
executeRascalShellBenchmark "MS05" "MOD17_EVALSYM_05"
executeRascalShellBenchmark "MT05" "MOD17_EVALTREE_05"
#
executeRascalShellBenchmark "ME10" "MOD17_EVALEXP_10"
executeRascalShellBenchmark "MS10" "MOD17_EVALSYM_10"
executeRascalShellBenchmark "MT10" "MOD17_EVALTREE_10"
#
executeRascalShellBenchmark "ME15" "MOD17_EVALEXP_15"
executeRascalShellBenchmark "MS15" "MOD17_EVALSYM_15"
executeRascalShellBenchmark "MT15" "MOD17_EVALTREE_15"
#
executeRascalShellBenchmark "ME20" "MOD17_EVALEXP_20"
executeRascalShellBenchmark "MS20" "MOD17_EVALSYM_20"
executeRascalShellBenchmark "MT20" "MOD17_EVALTREE_20"
# #
# # executeRascalShellBenchmark "ME25" "MOD17_EVALEXP_25" "8192m"
# # executeRascalShellBenchmark "MS25" "MOD17_EVALSYM_25" "8192m"
# # executeRascalShellBenchmark "MT25" "MOD17_EVALTREE_25" "8192m"
# # #
# # executeRascalShellBenchmark "ME30" "MOD17_EVALEXP_30" "8192m"
# # executeRascalShellBenchmark "MS30" "MOD17_EVALSYM_30" "8192m"
# # executeRascalShellBenchmark "MT30" "MOD17_EVALTREE_30" "8192m"

##
# Demonstration Sharability
###
executeJUnitBenchmark "S00" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_00"
executeJUnitBenchmark "S01" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_01"
executeJUnitBenchmark "S02" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_02"
executeJUnitBenchmark "S05" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_05"
executeJUnitBenchmark "S10" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_10"
executeJUnitBenchmark "S15A" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_15"
executeJUnitBenchmark "S15B" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_15" "256m"
executeJUnitBenchmark "S15C" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_15" "192m"
executeJUnitBenchmark "S15D" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_15" "128m"
executeJUnitBenchmark "S15E" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_15" "128m" "72m"
executeJUnitBenchmark "S20A" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_20"
executeJUnitBenchmark "S20B" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_20" "2048m"
executeJUnitBenchmark "S20C" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_20" "1024m"
# ...
executeJUnitBenchmark "S20E" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithShareableElements_20" "4096m" "128m"

##
# Demonstration Redundancy
###
executeJUnitBenchmark "U00" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements_00"
executeJUnitBenchmark "U01" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements_01"
executeJUnitBenchmark "U02" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements_02"
executeJUnitBenchmark "U05" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements_05"
executeJUnitBenchmark "U10" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements_10"
executeJUnitBenchmark "U15" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements_15"
executeJUnitBenchmark "U20" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testSingleTreeWithUniqueElements_20"

# # executeJUnitBenchmark "SME" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithShareableElementsAndMixedEqualitiesAnnotations"
# # executeJUnitBenchmark "UME" "org.eclipse.imp.pdb.values.benchmarks.MaximalSharingBenchmark#testTreeWithUniqueElementsAndMixedEqualitiesAnnotations"

executeJUnitBenchmark "D" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJHotDraw52"
executeJUnitBenchmark "E" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJWAM16FullAndreas"
executeJUnitBenchmark "F" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarEclipse202a"
executeJUnitBenchmark "G" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarjdk14v2"
executeJUnitBenchmark "H" "org.eclipse.imp.pdb.values.benchmarks.RelationResourceBenchmark#closureStarJDK140AWT"

# # executeJUnitBenchmark "RA" "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_5_000"
# # executeJUnitBenchmark "RB" "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_10_000"
# # executeJUnitBenchmark "RC" "org.eclipse.imp.pdb.values.benchmarks.SingleElementSetBenchmark#testUnionSingleElementIntegerSets_15_000"
# # #
# # executeJUnitBenchmark "S1" "org.eclipse.imp.pdb.values.benchmarks.ModelAggregationBenchmark"

executeJUnitBenchmark "RAND-IO" "org.eclipse.imp.pdb.test.fast.TestRandomValues#testIO"
executeJUnitBenchmark "RAND-AX" "org.eclipse.imp.pdb.test.fast.TestRandomValues#testAxioms"