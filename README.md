# XEP Dependency Graph
A script for visualizing dependency relationships of XEPs. Produces an output in .dot format for Graphviz to render.

## Dependencies
- [Graphviz][graphviz]

## Installation
- Install Perl modules: `carton install` or `cpanm --cpanfile cpanfile --installdeps -l local`

## Usage
Run the script and supply the location of a directory containing XEP XML files. The XSF repository is included as a git submodule (`git pull --recurse-submodules` if you haven't already).

```sh
./graph.pl ./xeps/ > graph.dot
```

Then render with Graphviz:

```sh
dot graph.dot -Tpdf > graph.pdf
sfdp graph.dot -Tpdf > graph-large.pdf
```

## Example Results
Here is an example graph of all Standards Track and Historical XEPs that are at least Active. Compliance suites and a few other things have been omitted from this demo to reduce density. Even in this reduced form, the output is quite interesting - note the Jingle cluster in the top right.

![Example graph output][demo-png]

Also included in this repository is a text-searchable [PDF version][demo-pdf] of the above graph, and the [raw .dot file][demo-dot].

[graphviz]: https://graphviz.org/
[demo-dot]: ./demo/demo.dot
[demo-png]: ./demo/demo.png
[demo-pdf]: ./demo/demo.pdf
