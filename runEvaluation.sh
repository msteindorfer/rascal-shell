export COMMON_VM_ARGS="-ea
-Xbootclasspath/a:/Users/Michael/.m2/repository/nl/cwi/jvmbmon/jvmbmon-native/0.0.1/jvmbmon-native-0.0.1.jar
-agentpath:/Users/Michael/Development/Data-Driven-Relations/libjvmbmon.dylib
-javaagent:/Users/Michael/.m2/repository/com/google/memory-measurer/1.0-SNAPSHOT/memory-measurer-1.0-SNAPSHOT.jar
" # -Djava.util.logging.config.file=logging.properties

java $COMMON_VM_ARGS -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark
java $COMMON_VM_ARGS -DsharingEnabled -jar target/rascal-shell-0.6.2-SNAPSHOT.jar -benchmark
