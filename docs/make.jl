using Documenter, ModiaResult, ModiaPlot_PyPlot

makedocs(
  #modules  = [ModiaResult],
  sitename = "ModiaResult",
  authors  = "Martin Otter (DLR-SR)",
  format = Documenter.HTML(prettyurls = false),
  pages    = [
     "Home"      => "index.md",
	 "Functions" => "Functions.md",
     "AbstractInterface" => "AbstractInterface.md",
  	 "Internal"  => "Internal.md",
  ]
)
