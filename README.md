# Parallel Image Processing Pipeline (Ubuntu Bash & Docker)

A high-performance, containerized batch image processing pipeline built in Ubuntu Bash. The pipeline leverages **ImageMagick** for complex image transformations and **GNU Parallel** to distribute workloads across multi-core CPU architectures, featuring automated CSV performance benchmarking.

---

## 🏗️ Architecture & Workflow

```text
               [ Raw Input Images (input/) ]
                             │
                             ▼
                [ Bash Pipeline Controller ]
                             │
   ┌─────────────────────────┼─────────────────────────┐
   │ (Core 1)                │ (Core 2)                │ (Core N)
   ▼                         ▼                         ▼
Grayscale Conversion      Grayscale Conversion      Grayscale Conversion
Gaussian Blur             Gaussian Blur             Gaussian Blur
Sobel Edge / Charcoal     Sobel Edge / Charcoal     Sobel Edge / Charcoal
Resize to 1080p           Resize to 1080p           Resize to 1080p
   │                         │                         │
   └─────────────────────────┼─────────────────────────┘
                             │
                             ▼
              [ Output Images (output/) ]
                         +
            [ Metrics Log (logs/benchmark_results.csv) ]
