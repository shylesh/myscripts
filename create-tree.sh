makedir () {

        local depth=$1
        local n=$2

        if [ $depth -eq 0 ]; then
                return
        fi


        for i in `seq 0  $2`
	do
                mkdir $i
		dd if=/dev/urandom of=file.$i bs=512k count=1
        done


        depth=$(($depth - 1))

	for i in `seq 0 $2`
	do
                pushd .
                cd $i
                makedir  $depth $2
                popd
        done


}

makedir  $1 $2 

