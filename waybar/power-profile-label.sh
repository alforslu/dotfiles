#!/bin/bash
case "$(powerprofilesctl get)" in
    performance)  echo "P"  ;;
    balanced)     echo "B"  ;;
    power-saver)  echo "PS" ;;
esac
