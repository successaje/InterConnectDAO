<?php
// Constant variable for Pi
define('PI', 22/7);


// Function to calculate the area of a circle
function getArea($radius) {
    return PI * $radius ** 2;
}

// Function to calculate the circumference of a circle
function getCircumference($radius) {
    return 2 * PI * $radius;
}

// Input from the user
$radius = floatval(readline("Enter the radius of the circle: "));

// Calculate and display the area and circumference
$area = getArea($radius);
$circumference = getCircumference($radius);

echo "The area of the circle is: $area\n";
echo "The circumference of the circle is: $circumference\n";
?>
