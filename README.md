# isolab for Galaxy #

This is Galaxy tool for R package
[IsotopicLabelling](https://github.com/RuggeroFerrazza/IsotopicLabelling)
which analyses mass spectrometric isotopic patterns obtained following
isotopic labelling experiments. For more details, see the
[IsotopicLabelling: an R package for the analysis of MS isotopic patterns of
labelled
analytes](https://academic.oup.com/bioinformatics/article/33/2/300/2525697).

## Installation ##

You need to install [Galaxy](https://github.com/galaxyproject/galaxy) and
[R](https://cran.r-project.org/) under Linux. 

- Install four R packages `optparse`, `WriteXLS`, `ecipex` and `gsubfn`
  inside R. 
- Do not install R package `IsotopicLabelling`. This tool includes it already. 
- Use `git` to clone this tool

  ```bash
  git clone https://github.com/wanchanglin/isolab.git
  ```

- Add this tool's location into Galaxy' tool config file:
  `~/Galaxy/config/tool_conf.xml`. For example, one simplified
  `tool_conf.xml` looks like:

  ```xml
  <?xml version='1.0' encoding='utf-8'?>
  <toolbox monitor="true">
    
    <section id="getext" name="Get Data">
      <tool file="data_source/upload.xml" />
    </section>
    
    <section id="MyTools" name="My Tools">
      <tool file="/path/to/isolab/isolab.xml" />
    </section>

  </toolbox>
  ```

## To-Do ##

- R package `ecipex` is not in BIOCONDA. (24-03-2019, Sun)
- White spaces in 'groups' input: Group factor delimiter is comma. No any
  extra white spaces are allowed otherwise an error will be encountered.
  Note that 'isolab.sh' has no problem with white spaces. Probably it is
  'Cheetah' or Galaxy's text input problem.(31-05-2018, Thu) 

## Authors, contributors & contacts ##

- Wanchang Lin (wl361@cam.ac.uk), University of Cambridge 
- Julian L Griffin (jlg40@cam.ac.uk), University of Cambridge 

