<?php

function getAverage($num1, $num2, $num3) {
    return ($num1 + $num2 + $num3) / 3;
}

// Input from the user
$num1 = floatval(readline("Enter the first number: "));
$num2 = floatval(readline("Enter the second number: "));
$num3 = floatval(readline("Enter the third number: "));

// Compute and display the average
$average = getAverage($num1, $num2, $num3);
echo "The average of $num1, $num2, and $num3 is: $average\n";

?>
