#[=======================================================================[.rst:
FindSphinx
-------

Finds the Sphinx documentation generator

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``Sphinx::Sphinx``
  The Sphinx executable

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``Sphinx_FOUND``
  True if the system has the Sphinx library.
``Sphinx_VERSION``
  The version of the Sphinx library which was found.

Functions
^^^^^^^^^

.. command:: sphinx_add_docs

  This function is intended as a convenience for adding a target for generating
  documentation with Sphinx.

  ::

    sphinx_add_docs(<targetBaseName>
        <configurationDir>
        <sourceDir>
        <baseOutputDir>
        [[DEPENDENCIES] <target>...])

  The function defines custom targets that runs Sphinx with the defined
  `conf.py` and source directory..

  So that relative input paths work as expected, by default the working
  directory of the Sphinx command will be the current source directory (i.e.
  :variable:`CMAKE_CURRENT_SOURCE_DIR`).

  The generated targets can be customized by setting ``SPHINX_<builder>_OUTPUT``
  CMake variables before calling ``sphinx_add_docs()``.
  Each of the following will be explicitly set, unless the variable already has
  a value before ``sphinx_add_docs()`` is called:

  .. variable:: SPHINX_HTML_OUTPUT

  Set to ``ON`` by this module.

  .. variable:: SPHINX_DIRHTML_OUTPUT

  Set to ``OFF`` by this module.

  .. variable:: SPHINX_HTMLHELP_OUTPUT

  Set to ``OFF`` by this module.

  .. variable:: SPHINX_QTHELP_OUTPUT

  Set to ``OFF`` by this module.

  .. variable:: SPHINX_DEVHELP_OUTPUT

  Set to ``OFF`` by this module.

  .. variable:: SPHINX_EPUB_OUTPUT

  Set to ``OFF`` by this module.

  .. variable:: SPHINX_LATEX_OUTPUT

  Set to ``OFF`` by this module.

  .. variable:: SPHINX_MAN_OUTPUT

  Set to ``OFF`` by this module.

  .. variable:: SPHINX_TEXT_OUTPUT

  Set to ``OFF`` by this module.
#]=======================================================================]

include(FindPackageHandleStandardArgs)

find_package(Python3 REQUIRED Interpreter)
get_filename_component(_python3_dir "${Python3_EXECUTABLE}" DIRECTORY)
execute_process(
        COMMAND "${Python3_EXECUTABLE}" -m site --user-base
        OUTPUT_VARIABLE _python3_user_base
        OUTPUT_STRIP_TRAILING_WHITESPACE)
find_program(Sphinx_EXECUTABLE
        NAMES
        sphinx-build
        HINTS
        "${_python3_user_base}/bin" #linux
        "${_python3_dir}/Scripts" #windows
        DOC "Sphinx documentation generator")
execute_process(
        COMMAND "${Sphinx_EXECUTABLE}" --v
        OUTPUT_VARIABLE _sphinx_version
        OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCH [[[0-9]+\.[0-9]+\.[0-9]+]]
        _sphinx_version
        "${_sphinx_version}")
find_package_handle_standard_args(Sphinx
        REQUIRED_VARS Sphinx_EXECUTABLE
        VERSION_VAR "${_sphinx_version}")

# Create an imported target for Sphinx
if (NOT TARGET Sphinx::sphinx)
    add_executable(Sphinx::sphinx IMPORTED GLOBAL)
    set_target_properties(Sphinx::sphinx
            PROPERTIES
            IMPORTED_LOCATION "${Sphinx_EXECUTABLE}")
endif ()

option(SPHINX_HTML_OUTPUT "Build a single HTML with the whole content." ON)
option(SPHINX_DIRHTML_OUTPUT "Build HTML pages, but with a single directory per document." OFF)
option(SPHINX_HTMLHELP_OUTPUT "Build HTML pages with additional information for building a documentation collection in htmlhelp." OFF)
option(SPHINX_QTHELP_OUTPUT "Build HTML pages with additional information for building a documentation collection in qthelp." OFF)
option(SPHINX_DEVHELP_OUTPUT "Build HTML pages with additional information for building a documentation collection in devhelp." OFF)
option(SPHINX_EPUB_OUTPUT "Build HTML pages with additional information for building a documentation collection in epub." OFF)
option(SPHINX_LATEX_OUTPUT "Build LaTeX sources that can be compiled to a PDF document using pdflatex." OFF)
option(SPHINX_MAN_OUTPUT "Build manual pages in groff format for UNIX systems." OFF)
option(SPHINX_TEXT_OUTPUT "Build plain text files." OFF)

mark_as_advanced(
        Sphinx_EXECUTABLE
        #        SPHINX_HTML_OUTPUT
        #        SPHINX_DIRHTML_OUTPUT
        #        SPHINX_HTMLHELP_OUTPUT
        #        SPHINX_QTHELP_OUTPUT
        #        SPHINX_DEVHELP_OUTPUT
        #        SPHINX_EPUB_OUTPUT
        #        SPHINX_LATEX_OUTPUT
        #        SPHINX_MAN_OUTPUT
        #        SPHINX_TEXT_OUTPUT
)

function(_sphinx_add_target target_name builder configuration_dir source_dir output_dir)
    add_custom_target(${target_name}
            COMMAND "${Sphinx_EXECUTABLE}"
            -b ${builder}
            -c "${configuration_dir}"
            "${source_dir}"
            "${output_dir}"
            VERBATIM
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            COMMENT "Generating sphinx documentation: ${builder}"
            )
    set_target_properties(${target_name}
            PROPERTIES
            ADDITIONAL_CLEAN_FILES "${output_dir}")
    if (${ARGN})
        add_dependencies(${target_name} ${ARGN})
    endif ()
endfunction()

function(sphinx_add_docs target_base_name configuration_dir source_dir base_output_dir #[[DEPENDENCIES]])
    set(multiValues DEPENDENCIES)
    cmake_parse_arguments("ARG"
            noValues
            singleValues
            "${multiValues}"
            ${ARGN})

    if (${SPHINX_HTML_OUTPUT})
        _sphinx_add_target(${target_base_name}_html html ${configuration_dir} ${source_dir} ${base_output_dir}/html ${ARG_DEPENDENCIES})
    endif ()
    if (${SPHINX_DIRHTML_OUTPUT})
        _sphinx_add_target(${target_base_name}_dirhtml dirhtml ${configuration_dir} ${source_dir} ${base_output_dir}/dirhtml ${ARG_DEPENDENCIES})
    endif ()
    if (${SPHINX_QTHELP_OUTPUT})
        _sphinx_add_target(${target_base_name}_qthelp qthelp ${configuration_dir} ${source_dir} ${base_output_dir}/qthelp ${ARG_DEPENDENCIES})
    endif ()
    if (${SPHINX_DEVHELP_OUTPUT})
        _sphinx_add_target(${target_base_name}_devhelp devhelp ${configuration_dir} ${source_dir} ${base_output_dir}/devhelp ${ARG_DEPENDENCIES})
    endif ()
    if (${SPHINX_EPUB_OUTPUT})
        _sphinx_add_target(${target_base_name}_epub epub ${configuration_dir} ${source_dir} ${base_output_dir}/epub ${ARG_DEPENDENCIES})
    endif ()
    if (${SPHINX_LATEX_OUTPUT})
        _sphinx_add_target(${target_base_name}_latex latex ${configuration_dir} ${source_dir} ${base_output_dir}/latex ${ARG_DEPENDENCIES})
    endif ()
    if (${SPHINX_MAN_OUTPUT})
        _sphinx_add_target(${target_base_name}_man man ${configuration_dir} ${source_dir} ${base_output_dir}/man ${ARG_DEPENDENCIES})
    endif ()
    if (${SPHINX_TEXT_OUTPUT})
        _sphinx_add_target(${target_base_name}_text text ${configuration_dir} ${source_dir} ${base_output_dir}/text ${ARG_DEPENDENCIES})
    endif ()
    if (${BUILD_TESTING})
        _sphinx_add_target(${target_base_name}_linkcheck linkcheck ${configuration_dir} ${source_dir} ${base_output_dir}/linkcheck ${ARG_DEPENDENCIES})
    endif ()
endfunction()