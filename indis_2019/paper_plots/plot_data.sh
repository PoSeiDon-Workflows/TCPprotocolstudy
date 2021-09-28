#!/usr/bin/env bash

mkdir -p plots

flows=(elephant mice)
algos=(cubic reno hamilton bbr)


# plot retransmissions
for flow in ${flows[@]}; do
   for algo in ${algos[@]}; do
      echo "Retransmissions: ${flow} - ${algo}"
      output_file="plots/${flow}_retransmit_${algo}.png"
      #output_file="plots/${flow}_retransmit_${algo}.tex"
      input_dir="../${algo}/source/processed"
      echo $input_dir
      echo $output_file

gnuplot<<EOC
    reset
    #set terminal epslatex size 3.5,2.62 color colortext
    set terminal png size 1200,700 font 'Arial,18'
    set output "${output_file}"
    #set datafile separator " "
    
    #set title 'Worker: Average Disk Await (Docker NFS Symlinks)' noenhanced
    set notitle
    set ylabel '{/:Bold Number of Bytes Retransmitted}'
    set xlabel '{/:Bold Sample}'
    
    set yrange[0:]
    set key outside center top horizontal Left samplen 2 reverse
    set grid
    unset border
    plot '${input_dir}/normal/${flow}.log' using 11 with points pointtype 7 ps 1.5 title 'Normal' noenhanced,\
         '${input_dir}/loss_0.1/${flow}.log' using 11 with points pointtype 7 ps 1.5 title 'Loss 0.1%' noenhanced,\
         '${input_dir}/loss_0.5/${flow}.log' using 11 with points pointtype 7 ps 1.5 title 'Loss 0.5%' noenhanced,\
         '${input_dir}/loss_1/${flow}.log' using 11 with points pointtype 7 ps 1.5 title 'Loss 1%' noenhanced,\
         '${input_dir}/duplicate_1/${flow}.log' using 11 with points pointtype 7 ps 1.5 title 'Duplicate 1%' noenhanced,\
         '${input_dir}/duplicate_5/${flow}.log' using 11 with points pointtype 7 ps 1.5 title 'Duplicate 5%' noenhanced,\
         '${input_dir}/reorder_25/${flow}.log' using 11 with points pointtype 7 ps 1.5 title 'Reorder 25%' noenhanced,\
         '${input_dir}/reorder_50/${flow}.log' using 11 with points pointtype 7 ps 1.5 title 'Reorder 50%' noenhanced
EOC

done
done

# plot throughput
for flow in ${flows[@]}; do
   for algo in ${algos[@]}; do
      echo "Throughput: ${flow} - ${algo}"
      output_file="plots/${flow}_throughput_${algo}.png"
      #output_file="plots/${flow}_throughput_${algo}.tex"
      input_dir="../${algo}/source/processed"
      echo $input_dir
      echo $output_file

gnuplot<<EOC
    reset
    #set terminal epslatex size 3.5,2.62 color colortext
    #set terminal pdf size 3.5,2.2 font 'Arial,13'
    set terminal png size 1200,700 font 'Arial,18'
    set output "${output_file}"
    #set datafile separator " "
    
    set style fill solid 0.5 border -1
    set style boxplot outliers pointtype 7
    set style data boxplot
    set boxwidth  0.5
    set pointsize 0.5

    #set title 'Worker: Average Disk Await (Docker NFS Symlinks)' noenhanced
    set notitle
    set ylabel '{/:Bold Throughput (Mbps)}'
    set xlabel '{/:Bold Anomaly Type}' offset 0,-1
    
    #set xtics ("Normal" 1, "Loss 0.1%%" 2, "Loss 0.5%%" 3, "Loss 1%%" 4, "Duplicate 1%%" 5, "Duplicate 5%%" 6, "Reorder 25%%" 7, "Reorder 50%%" 8) noenhanced center offset 0,-1 rotate by -20
    set xtics ("Normal" 1, "Loss\n0.1%%" 2, "Loss\n0.5%%" 3, "Loss\n1%%" 4, "Dupl.\n1%%" 5, "Dupl.\n5%%" 6, "Reor.\n25%%" 7, "Reor.\n50%%" 8) noenhanced
    #set xtics ("Normal" 1, "0.1%%\nLoss" 2, "0.5%%\nLoss" 3, "1%%\nLoss" 4, "1%%\nDupl." 5, "5%%\nDupl." 6, "25%%\nReor." 7, "50%%\nReor." 8) noenhanced
    set yrange[0:]
    unset key
    set grid
    unset border
    plot '${input_dir}/normal/${flow}.log' using (1):((\$9*8)/(\$30-\$29)/1000) ps 1.5 notitle,\
         '${input_dir}/loss_0.1/${flow}.log' using (2):((\$9*8)/(\$30-\$29)/1000) ps 1.5 notitle,\
         '${input_dir}/loss_0.5/${flow}.log' using (3):((\$9*8)/(\$30-\$29)/1000) ps 1.5 notitle,\
         '${input_dir}/loss_1/${flow}.log' using (4):((\$9*8)/(\$30-\$29)/1000) ps 1.5 notitle,\
         '${input_dir}/duplicate_1/${flow}.log' using (5):((\$9*8)/(\$30-\$29)/1000) ps 1.5 notitle,\
         '${input_dir}/duplicate_5/${flow}.log' using (6):((\$9*8)/(\$30-\$29)/1000) ps 1.5 notitle,\
         '${input_dir}/reorder_25/${flow}.log' using (7):((\$9*8)/(\$30-\$29)/1000) ps 1.5 notitle,\
         '${input_dir}/reorder_50/${flow}.log' using (8):((\$9*8)/(\$30-\$29)/1000) ps 1.5 notitle
EOC

done
done

# plot predictions
flows=(elephant mice 1000genome)
for flow in ${flows[@]}; do
   for algo in ${algos[@]}; do
      echo "Prediction: ${flow} - ${algo}"
      output_file="plots/${flow}_predictions_${algo}.png"
      #output_file="plots/${flow}_predictions_${algo}.tex"
      input_file="ml_stats/${flow}_predictions_${algo}.dat"
      echo $input_file
      echo $output_file

gnuplot<<EOC
    reset
    #set terminal epslatex size 3.5,2.62 color colortext
    #set terminal pdf size 3.5,2.2 font 'Arial,13'
    set terminal png size 1200,700 font 'Arial,18'
    set output "${output_file}"
    #set datafile separator " "
    
    set style fill solid 0.5 border -1
    set style data histogram
    set style histogram cluster gap 3
    set boxwidth 0.9
    
    #set title 'Worker: Average Disk Await (Docker NFS Symlinks)' noenhanced
    set notitle
    set ylabel '{/:Bold Prediction (%)}'
    set xlabel '{/:Bold Test Data}'
    
    set xtics ("Normal" 0, "Loss" 1, "Duplicate" 2, "Reorder" 3) noenhanced
    set yrange[0:]
    #set key outside center top horizontal samplen 2
    set key outside center top horizontal Left samplen 2 reverse
    set grid
    unset border
    plot '${input_file}' using 2 title "Predicted Normal",\
         '' using 3 title "Predicted Loss",\
         '' using 4 title "Predicted Duplication",\
         '' using 5 title "Predicted Reordering"
EOC
done
done

# plot accuracy
echo "Accuracy"
output_file="plots/accuracy_predictions.png"
#output_file="plots/accuracy_predictions.tex"
input_file="ml_stats/accuracy_predictions.dat"
echo $input_file
echo $output_file

gnuplot<<EOC
    reset
    #set terminal epslatex size 3.5,2.62 color colortext
    #set terminal pdf size 3.5,2.2 font 'Arial,13'
    set terminal png size 1200,700 font 'Arial,18'
    set output "${output_file}"
    #set datafile separator " "
    
    set style fill solid 0.5 border -1
    set style data histogram
    set style histogram cluster gap 3
    set boxwidth 0.9
    
    #set title 'Worker: Average Disk Await (Docker NFS Symlinks)' noenhanced
    set notitle
    set ylabel '{/:Bold Accuracy Rate}'
    set xlabel '{/:Bold Classifier}'
    
    set xtics ("Cubic" 0, "Reno" 1, "Hamilton" 2, "BBR" 3) noenhanced
    set yrange[0:]
    #set key outside center top horizontal samplen 2
    set key outside center top horizontal Left samplen 2 reverse
    set grid
    unset border
    plot '${input_file}' using 2 title "Elephant Flows",\
         '' using 3 title "Mice Flows"
#,\
#     '' using 4 title "1000Genome Workflow"
EOC


# plot osg predictions
echo "OSG Predictions"
output_file="plots/osg_predictions.png"
input_file="ml_stats/osg_predictions.dat"
echo $input_file
echo $output_file

gnuplot<<EOC
    reset
    #set terminal epslatex size 3.5,2.62 color colortext
    #set terminal pdf size 3.5,2.2 font 'Arial,13'
    set terminal png size 1200,700 font 'Arial,18'
    set output "${output_file}"
    #set datafile separator " "
    
    set style fill solid 0.5 border -1
    set style data histogram
    set style histogram cluster gap 3
    set boxwidth 0.9
    
    #set title 'Worker: Average Disk Await (Docker NFS Symlinks)' noenhanced
    set notitle
    set ylabel '{/:Bold Prediction (%)}'
    set xlabel '{/:Bold Classifier}'
    
    set xtics ("Cubic" 0, "Reno" 1, "Hamilton" 2, "BBR" 3) noenhanced
    set yrange[0:]
    #set key outside center top horizontal samplen 2
    #set key outside center top horizontal Left samplen 2 width -4
    set key outside center top horizontal Left samplen 2 reverse
    set grid
    unset border
    plot '${input_file}' using 2 title "Predicted Normal",\
         '' using 3 title "Predicted Loss",\
         '' using 4 title "Predicted Duplication",\
         '' using 5 title "Predicted Reordering"
EOC
