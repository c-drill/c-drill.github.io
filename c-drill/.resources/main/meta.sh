#!/bin/bash
EXAM_TITLE="42 Piscine C - Final Exam Simulator"
META_LEVELS="0 1 2 3 4 5 6 7 8 9 10"
MAX_SCORE=100
EXAM_DURATION=28800   # 8 hours
meta_level_subjects(){ case "$1" in
  0) echo "hello ft_countdown maff_alpha ft_stars ft_print_numbers" ;;
  1) echo "fizzbuzz buzzfizz ft_putnbr" ;;
  2) echo "ft_add ft_sub ft_mul ft_add_n ft_swap" ;;
  3) echo "ft_strlen ft_putstr occ_z occ_a" ;;
  4) echo "aff_first_param aff_last_param" ;;
  5) echo "ft_atoi ft_itoa" ;;
  6) echo "ft_split" ;;
  7) echo "print_odd replace_3_5 rot_13 rotone search_and_replace ulstr first_word last_word alpha_mirror repeat_alpha" ;;
  8) echo "inter union wdmatch" ;;
  9) echo "ft_range ft_rrange" ;;
  10) echo "count_alpha" ;;
esac ; }
meta_level_points(){ case "$1" in 0)echo 5;;1)echo 6;;2)echo 7;;3)echo 8;;4)echo 5;;5)echo 6;;6)echo 6;;7)echo 7;;8)echo 6;;9)echo 6;;10)echo 6;;esac ; }
