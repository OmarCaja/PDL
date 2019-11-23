#!/bin/bash
: ${MENOSCCFLAGS:= ""}
: ${TESTDIR:= "./tmp/tests_asignatura"}
printf "[INFO]\tset env var TESTDIR with desired tests directory\n"
printf "[INFO]\tTESTSDIR is ./tmp by default\n"
printf "[INFO]\tset env var MENOSCCFLAGS with -d to show the parsing trace\n"
printf "[INFO]\tMENOSCCFLAGS=\"-d\" run_test.sh\n"
printf "\n[INFO] Test files:\n"
for file in ${TESTDIR}/*.c; do echo $file; done
for file in ${TESTDIR}/*.c; do
	echo "*******************************************************************************";
	echo "Testing: $file...." ;
	grep // $file -n
	./menoscc -f $file ${MENOSCCFLAGS};
done
echo "Test complete! ^.^"
