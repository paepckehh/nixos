# Go Slice Internals

> **Source**: Effective Go

---

## The Three-Item Descriptor

A slice is a runtime data structure with three components:

- **Pointer**: Address of the first accessible element
- **Length**: Number of elements (`len(s)`)
- **Capacity**: Max elements to end of underlying array (`cap(s)`)

```go
arr := [5]int{10, 20, 30, 40, 50}
s := arr[1:4]  // s = [20, 30, 40]
// pointer: &arr[1], length: 3, capacity: 4
```

A `nil` slice has all three items set to zero/nil.

---

## Slices Reference Underlying Arrays

Slices don't store data—they describe a section of an array:

```go
data := [4]int{1, 2, 3, 4}
a := data[0:2]  // [1, 2]
b := data[1:3]  // [2, 3]

b[0] = 99
fmt.Println(a)    // [1, 99] - both see the change
fmt.Println(data) // [1, 99, 3, 4]
```

---

## The Slice Operator

`s[lo:hi]` creates a slice from index `lo` to `hi-1`:

```go
s := []int{0, 1, 2, 3, 4, 5}
s[2:4]   // [2, 3]
s[:3]    // [0, 1, 2]
s[3:]    // [3, 4, 5]
```

Three-index form `s[lo:hi:max]` limits capacity to `max-lo`.

---

## Why append Must Return the Slice

The slice header is passed **by value**. Functions can modify elements but
cannot change the caller's header:

```go
func Append(slice, data []byte) []byte {
    l := len(slice)
    if l+len(data) > cap(slice) {
        newSlice := make([]byte, (l+len(data))*2)
        copy(newSlice, slice)
        slice = newSlice  // Only changes local variable
    }
    slice = slice[0 : l+len(data)]
    copy(slice[l:], data)
    return slice  // Caller must receive the new header
}
```

When reallocation occurs, `slice` points to a new array. The caller's original
still points to the old one—returning lets them update their reference.

---

## The copy Function

`copy(dst, src)` copies elements and returns the count copied:

```go
src := []int{1, 2, 3, 4, 5}
dst := make([]int, 3)
n := copy(dst, src)  // n=3, dst=[1,2,3]
```

Handles overlapping slices correctly. Copies `min(len(dst), len(src))`
elements—no reallocation occurs.

---

## Slice Gotchas

### 1. Shared Underlying Array

```go
original := []int{1, 2, 3, 4, 5}
subset := original[1:3]
subset[0] = 99
fmt.Println(original)  // [1, 99, 3, 4, 5] - modified!

// Fix: make independent copy
subset := make([]int, 2)
copy(subset, original[1:3])
```

### 2. Append May or May Not Reallocate

```go
a := make([]int, 3, 5)  // len=3, cap=5
b := a[0:3]
a = append(a, 4)    // Fits in capacity - still shared
a = append(a, 5, 6) // Exceeds capacity - now independent
```

### 3. Memory Leaks from Large Backing Arrays

```go
// Bad: small slice keeps entire file in memory
func getHeader(file []byte) []byte { return file[:100] }

// Good: copy to release the large array
func getHeader(file []byte) []byte {
    header := make([]byte, 100)
    copy(header, file)
    return header
}
```

### 4. Nil vs Empty Slice

```go
var nilSlice []int     // nil, len=0, cap=0
emptySlice := []int{}  // non-nil, len=0, cap=0
// Both work identically with len, cap, append, range
// Prefer nil for uninitialized state
```

## Quick Reference

| Operation | Behavior |
|-----------|----------|
| `s[lo:hi]` | Slice from lo to hi-1 |
| `s[lo:hi:max]` | Slice with capacity limited to max-lo |
| `append(s, x...)` | Returns new slice; may reallocate |
| `copy(dst, src)` | Returns count copied; no reallocation |
