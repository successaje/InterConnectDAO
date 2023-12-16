
def getAverage(num1, num2, num3):  #decalaring the function and taking the 3 numbers as inputs
    return ((num1 + num2 + num3) / 3) #returns the average of the 3 numbers

# Input numbers from the user
#You can use integers too, but float is safer sha
num1 = float(input("Enter the first number: "))
num2 = float(input("Enter the second number: "))
num3 = float(input("Enter the third number: "))

# Compute and display the average
average = getAverage(num1, num2, num3) #This line basically call the function and parse the inputs as arguments

print(f"The average of {num1}, {num2}, and {num3} is: {average}")
