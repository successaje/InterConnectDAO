
# Constant variable for Pi
PI : float = (22/7)

# Function to calculate the area of a circle
def getArea(radius):
    return (PI * (radius**2))

# Function to calculate the circumference of a circle
def getCircumference(radius):
    return (2 * PI * radius)

# Input from the user
radius = float(input("Enter the radius of the circle: "))

# Calculate and display the area and circumference
area = getArea(radius)
circumference = getCircumference(radius)

print(f"The area of the circle is: {area}")
print(f"The circumference of the circle is: {circumference}")
