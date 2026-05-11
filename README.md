# Signal Segmentation Toolkit

A high-performance, vectorized toolkit for signal segmentation, Run-Length Encoding (RLE), state-change detection, and strict monotonic enforcement. 

## Why use this toolkit?
* **Dependency-Free**: Works out-of-the-box using base MATLAB algorithms. Zero reliance on toolboxes (like Image Processing or Signal Processing).
* **Vectorized Performance**: Built with JIT-optimized, loop-free architectures capable of handling massive 1D signals and complex N-dimensional arrays efficiently.
* **Sequential Contiguity**: Unlike standard grouping functions that rely on hashing or sorting scattered data, these tools are explicitly designed to respect temporal and sequential block structures.
* **Global Trend Awareness**: Features completely original algorithms for monotonic filtering that rely on global cumulative logic rather than fragile local derivatives.

## Available Functions

### Morphology & Segmentation
* `bounds`: High-performance RLE analyzer returning start, end, and length indices of contiguous segments.
* `collect`: Direct memory slicer that cuts multi-channel data into cells based on mask boundaries.
* `labels`: Vectorized state-change counter that transforms arrays into sequential ID maps.
* `modify`: 1D morphological engine to precisely expand (dilate), shrink (erode), or slide segments.
* `prune`: Ultra-fast length filter to eliminate non-conforming short segments without loops.
* `locate`: State-machine driven steady-state detector with fallback architectures for safety.

### Monotonicity Enforcement
* `nonMonotonicMask`: Identifies violations of strictly increasing trends. Utilizes an original **Global Cumulative Strategy** (`cummax`/`cummin`) to robustly mark entire non-monotonic clusters (backward flows or stalls) rather than just local drops.
* `rmNonMonotonic`: A "Gatekeeper" function that utilizes the mask to clean a reference vector and synchronously slice any associated multi-dimensional data arrays.

## Installation
Clone the repository and add the root directory (the folder containing the `+sovs` namespace) to your MATLAB path.

~~~matlab
addpath('path/to/signal-segmentation-toolkit')
~~~

## Usage
This toolkit uses a professional namespace (`sovs.segment`) to prevent conflicts with other toolboxes. You can use the functions directly via their full path:

~~~matlab
% Direct usage
starts = sovs.segment.bounds(mySignal);
~~~

Or, you can import the package at the top of your script for cleaner code:

~~~matlab
% Import the entire package
import sovs.segment.*

% Now you can call the functions normally
starts = bounds(mySignal);
cleanSignal = rmNonMonotonic(mySignal);
~~~

## Acknowledgments
The core algorithms, logic, and original concepts (such as the global cumulative approach for monotonic masking) were exclusively designed and implemented by the author. Google Gemini was utilized as an AI assistant to collaborate on code refactoring, structural optimization, and drafting this documentation.
