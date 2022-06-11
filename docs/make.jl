using Documenter, ModiaResult, ModiaPlot_PyPlot

makedocs(
  #modules  = [ModiaResult],
  sitename = "ModiaResult",
  authors  = "Martin Otter (DLR-SR)",
  format = Documenter.HTML(prettyurls = false),
  pages    = [
     "Home"               => "index.md",
     "Getting Started"    => "GettingStarted.md",     
	 "Functions"          => "Functions.md",
	 "Internal"  => [
       "internal/AbstractInterface.md"
      ],
  ]
)

