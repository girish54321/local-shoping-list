

const sumOfSqueares = (arr) => {
    return arr.reduce((acc, num) => {
        return acc + (num * num);
    }, 0);
}

console.log(sumOfSqueares([1, 2, 3, 4, 5])); // Output: 55