#!/bin/bash

set -x
set -e

. ./gpupack.sh

function submit ()
{
  N=$1
  p=$2
  script=$3
  pack=$4
  grid=$5

  ppack=$(basename $pack)

  out="$GPUPACK_PREFIX/cy49/arp/$grid/ref/$ppack/slurm.out"

  if [ -f "$out" ]
  then
    if [ "$p" = "ndl" ]
    then
      sbatch --gres=gpu:4 --exclusive --switches=3 -N$N -p $p  cy49/arp/arp.sh $pack $grid
    else
      sbatch --exclusive -N$N -p $p  cy49/arp/arp.sh $pack $grid
    fi
  else
    mkdir -p $(dirname $out)
    if [ "$p" = "ndl" ]
    then
      sbatch --gres=gpu:4 --exclusive --switches=3 -o $out -N$N -p $p  cy49/arp/arp.sh $pack $grid
    else
      sbatch --exclusive -o $out -N$N -p $p  cy49/arp/arp.sh $pack $grid
    fi
  fi
}


CYCLE=49t2
BRANCH=openacc



for ARCH in NVHPC2403ECTRANSGPU.1d NVHPC2403ECTRANSGPU.1s NVHPC2403.1d INTEL2302.2s INTEL2302.2d NVHPC2403.1s
do
  for TRUNC in t0031 t0107 t0538 t0798
  do

    if [ ${ARCH:0:5} = "INTEL" ]
    then
      partition=normal256
    else
      partition=ndl
    fi

    if [ "$TRUNC" = "t0798" ]
    then
      nodes=3
    elif [ "$TRUNC" = "t0538" ]
    then
      nodes=2
    else
      nodes=1
    fi

    submit $nodes $partition cy49/arp/arp.sh $GPUPACK_PREFIX/pack/${CYCLE}_${BRANCH}.01.${ARCH} $TRUNC

  done
done
