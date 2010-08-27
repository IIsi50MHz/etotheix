CD C:\My Dropbox\etotheix\structure stylesheet\extendedXSLT
xsltproc --output sss_ex_compiled.xsl --timing  sss_compile.xsl sss_ex.xml
xsltproc --output sss_ex_transformed.html --timing  sss_ex_compiled.xsl expample_doc.xml
PAUSE


