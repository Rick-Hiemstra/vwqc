vim9script

if !has('vim9script') ||  v:version < 901
    echoerr 'Needs Vim version 9.1 and above'
    finish
endif
# -----------------------------------------------------------------
# ----------------- DECLARE THIS A VIMSCRIPT 9 SCRIPT -------------
# -----------------------------------------------------------------

#__     ___                   _ _    _ 
#\ \   / (_)_ __ _____      _(_) | _(_)
# \ \ / /| | '_ ` _ \ \ /\ / / | |/ / |
#  \ V / | | | | | | \ V  V /| |   <| |
#   \_/  |_|_| |_| |_|\_/\_/ |_|_|\_\_|
#                                      
#  ___              _ _ _        _   _              ____          _      
# / _ \ _   _  __ _| (_) |_ __ _| |_(_)_   _____   / ___|___   __| | ___ 
#| | | | | | |/ _` | | | __/ _` | __| \ \ / / _ \ | |   / _ \ / _` |/ _ \
#| |_| | |_| | (_| | | | || (_| | |_| |\ V /  __/ | |__| (_) | (_| |  __/
# \__\_\\__,_|\__,_|_|_|\__\__,_|\__|_| \_/ \___|  \____\___/ \__,_|\___|
#                                                                       
# -----------------------------------------------------------------
# ------------------------ VWQC PLUG-IN ---------------------------
# -----------------------------------------------------------------
# Vimwiki Qualitative Code (VWQC) - Vimscript 9 version
# Written by Rick Hiemstra and Lindsay Callaway
# Version 0.1 - 
# 2024-04-02	
#
# Updated help menus to reflect recent coding changes
#
# Added an autogroup that checks to see if the current vwqc wiki's tags are
# loaded.
#
# -----------------------------------------------------------------
# ------------------------ TO DO ------------------------------
# -----------------------------------------------------------------
# Update page help
# Modify the file names when reports are created by AllSummaries() so that the
# name reflects the function origin.
# Could you do this with ripgrep to get more speed? Then you process the lines
# Re-format the how attributes are handled
# Write a function to modify the attribute lines in the old wikis.
#
# Change Vimwiki so g:current_tags is only deepcopied if it is an interview
# wiki. Add wiki_x.vwqc = 1 to interview wikis to identify interview wikis.
# This will make sure that the tag completion behavior isn't compromised on
# non-vwqc wikis.
#
# Change the Gather() function so that it will give you an error message if
# you try to use it in a non-quotes report (or other kind of buffer).
#
# Add the .vwqc key-value pair to the wiki definitions.
# 

# -----------------------------------------------------------------
# ------------------------ FUNCTIONS ------------------------------
# -----------------------------------------------------------------
#
# ---- Setup ----
# HelpMenu
# ProjectSetup
# CreateDefaultInterviewHeader
# GetVWQCProjectParameters
# ListProjectParameters
# ParmCheck
# DoesFileNameMatchLabelRegex
# FormatInterview
# FormatInterviewB
# AugmentVimwikiLocalVars
# PageHelp
# DisplayPageHelp
# CreateBackupQuery
# CreateBackup
#
# ---- Annotations ----
# Annotation
# ExitAnnotation
# AnnotationToggle
# DeleteAnnotation
#
# ---- Navigation ----
# GoToReference
# GoBackFromReference
#
# ---- Reports ----
# FullReport
# AnnotationsReport
# QuotesReport
# MetaReport
# VWSReport
# AllSummariesFull
# AllSummariesGenReportsFull
# AllSummariesQuotes
# AllSummariesGenReportsQuotes
# GenSummaryLists
# Gather
# Report
#
# GetInterviewFileList
# CrawBufferTags
# CalcInterviewTagCrosstabs
# FindLargestTagAndBlockCounts
# PrintInterviewTagSummary
# PrintTagInterviewSummary
# GraphInterviewTagSummary
# GraphTagInterviewSummary
# CreateUniqueTagList
# FindLengthOfLongestTag
# TagStats
#
# PopulateQuoteLineList
# ProcessInterviewLines
# ProcessInterviewTitle
# GetInterviewLineInfo
# CreateSummaryCountTableLine
#
# ProcessAnnotationLines
# PopulateAnnoLineList
# GetAnnoInterview
# GetAnnoText
#
# CreateCSVRecord
# FindBufferType
# RemoveMetadata
# AddReportHeader
# GetAttributeLine
# 
# ---- Trimming Quotes ----
# TrimLeadingPartialSentence
# TrimTrailingPartialSentence
# TrimLeadingAndTrailingPartialSentence
#
# ---- Tags ----
# GetTagUpdate
# UpdateCurrentTagsPage 
# UpdateCurrentTagsList
# TagsGenThisSession
# ToggleDoubleColonOmniComplete
# GenDictTagList
# CreateTagDict
# CurrentTagsPopUpMenu
# NoTagListNotice 
# TagFillWithChoice
# FindLastTagAddedToBuffer
# FillChosenTag
# ChangeTagFillOption
# SortTagDefs
# GetTagDef
# GetTagUnderCursor
# AddNewTagDef
# 
# ---- Attributes ----
# GetInterviewFileList
# Attributes
# ColSort
#
# ---- Other ----
# UpdateSubcode


# -----------------------------------------------------------------
# ---------------------------- VWQC SETUP -------------------------
# -----------------------------------------------------------------

# ------------------------------------------------------
# Displays a popup help menu
# ------------------------------------------------------
def HelpMenu()
	var g:help_list = [             "NAVIGATION", 
		                        "<leader>gt                          Go to",
					"<leader>gb                          Go back", 
				 	"<F7>                                Annotation Toggle", 
				        " " , 
				     	"CODING", 
					"<F2>                                Update tags", 
					"<F8>                                Tag omni-complete, same as <F9>",
					"<F9>                                Tag omni-complete, same as <F8>",
					"<F5>                                Complete tag block",
					"<F4>                                Toggle tag block completion mode",
					"<leader>tf                          Tag fill",
					"<leader>da                          Delete annotation",
					"<leader>df                          Get/define tag definition",
					"<leader>tc                          Double-colon omni-complete toggle",
				        " ",
					"REPORTS",
					":call FullReport(\"<tag>\")           Create full tag summary",
					":call AnnotationsReport(\"<tag>\")    Create tag annotations summary",
					":call QuotesReport(\"<tag>\")         Create tag report for coded interview lines",
					":call MetaReport(\"<tag>\")           Create tag report for with line metadata",
					":call VWSReport(\"<string>\")         Create custom search report", 
					":call Gather(\"<tag>\")               Create secondary tag sub-report", 
					":call AllSummariesFull()            Create FullReport summaries for all tags in tag glossary", 
					":call AllSummariesQuotes()          Create QuotesReport summaries for all tags in tag glossary", 
					":call TagStats()                    Create tables and graphs by tag and interview", 
				        " ",
					"WORKING WITH REPORTS",
					"<leader>th                          Trim head",
					"<leader>tt                          Trim tail",
					"<leader>ta                          Trim head and tail", 
				        " ",
				 	"APPARATUS",
					":call Attributes(<sort col number>) Create attribute table and sort by column number",
					":call SortTagDefs()                 Sort tag definition list inside Tag Glossary page",
					":call FormatInterview(\"<label>\")    Format interview page",
					"<leader>rs                          Resize windows",
					"<leader>bk                          Create project backup",
					"<leader>hm                          Help menu",
					"<leader>ph                          Page help",
				        "<leader>lp                          List project parameters"]
	popup_menu(g:help_list , 
				 { minwidth: 50,
				 maxwidth: 100,
				 pos: 'center',
				 border: [],
				 close: 'click',
				 })
enddef

#function HelpMenu() 
#	let g:help_list = [              "NAVIGATION", 
#		                \        "<leader>gt                          Go to",
#				\	 "<leader>gb                          Go back", 
#				\ 	 "<F7>                                Annotation Toggle", 
#				\        " " , 
#				\     	 "CODING", 
#				\	 "<F2>                                Update tags", 
#				\	 "<F8>                                Tag omni-complete, same as <F9>",
#				\	 "<F9>                                Tag omni-complete, same as <F8>",
#				\	 "<F5>                                Complete tag block",
#				\	 "<F4>                                Toggle tag block completion mode",
#				\	 "<leader>tf                          Tag fill",
#				\	 "<leader>da                          Delete annotation",
#				\	 "<leader>df                          Get/define tag definition",
#				\	 "<leader>tc                          Double-colon omni-complete toggle",
#				\        " ",
#				\	 "REPORTS",
#				\	 ":call FullReport(\"<tag>\")           Create full tag summary",
#				\	 ":call AnnotationsReport(\"<tag>\")    Create tag annotations summary",
#				\	 ":call QuotesReport(\"<tag>\")         Create tag report for coded interview lines",
#				\	 ":call MetaReport(\"<tag>\")           Create tag report for with line metadata",
#				\	 ":call VWSReport(\"<string>\")         Create custom search report", 
#				\	 ":call Gather(\"<tag>\")               Create secondary tag sub-report", 
#				\	 ":call AllSummariesFull()            Create FullReport summaries for all tags in tag glossary", 
#				\	 ":call AllSummariesQuotes()          Create QuotesReport summaries for all tags in tag glossary", 
#				\	 ":call TagStats()                    Create tables and graphs by tag and interview", 
#				\        " ",
#				\	 "WORKING WITH REPORTS",
#				\	 "<leader>th                          Trim head",
#				\	 "<leader>tt                          Trim tail",
#				\	 "<leader>ta                          Trim head and tail", 
#				\        " ",
#				\ 	 "APPARATUS",
#				\	 ":call Attributes(<sort col number>) Create attribute table and sort by column number",
#				\	 ":call SortTagDefs()                 Sort tag definition list inside Tag Glossary page",
#				\	 ":call FormatInterview(\"<label>\")    Format interview page",
#				\	 "<leader>rs                          Resize windows",
#				\	 "<leader>bk                          Create project backup",
#				\	 "<leader>hm                          Help menu",
#				\	 "<leader>ph                          Page help",
#				\        "<leader>lp                          List project parameters"]
#	call popup_menu(g:help_list , 
#				\ #{ minwidth: 50,
#				\ maxwidth: 100,
#				\ pos: 'center',
#				\ border: [],
#				\ close: 'click',
#				\ })
#endfunction
# ------------------------------------------------------
# This sets up a project from a blank Vimwiki index page
# ------------------------------------------------------

function ProjectSetup() 
	execute "normal! gg"
	let g:index_page_content_test = search('\S', 'W')
	if (g:index_page_content_test != 0)
		let l:index_already_created = "The index page already has content.\n\nSetup not performed."
		call confirm(l:index_already_created,  "OK", 1)
	else
		execute "normal! O## <Project Title> ##\n\n[Tag Glossary](Tag Glossary)\n[Tag List Current](Tag List Current)\n"
		execute "normal! i[Attributes](Attributes)\n[Style Guide](Style Guide)\n\n## Interviews ##\n"
		execute "normal! i\no = Needs to be coded; p = in process; x = first pass done; z = second pass done\n\n"
		execute "normal! i[o] \n[o] \n[o] \n[o] \n\n## Tag Summaries ##\n\n"

		call GetVWQCProjectParameters()

		call mkdir(g:extras_path, "p")
		call mkdir(g:tag_summaries_path, "p")

		let l:extras_path_creation_message = "A directory for additional project files has been created at:\n\n" . g:extras_path
		call confirm(l:extras_path_creation_message,  "OK", 1)

		let l:backup_path_creation_message = "A directory for project backups has been created at:\n\n" . g:backup_path
		call confirm(l:backup_path_creation_message,  "OK", 1)

		let l:tag_summaries_path_creation_message = "A directory for CSV tag summaries has been created at:\n\n" . g:tag_summaries_path . "\n\nFiles will appear here after you create summary reports"
		call confirm(l:tag_summaries_path_creation_message,  "OK", 1)

		call CreateDefaultInterviewHeader()
	       	let l:template_message       = "A default interview header template has been created here:\n\n" . g:int_header_template . "\n\nModify it to your project's specifications before formatting interviews."
		call confirm(l:template_message,  "OK", 1)
	endif
endfunction                        

# -----------------------------------------------------------------
# This function creates a simple default interview header
# -----------------------------------------------------------------
function CreateDefaultInterviewHeader() 
	if (filereadable(g:int_header_template) == 0) 
                # leave a space at the beginning of the list of attributes. It
		# affects how the first attribute tag is found.
		let l:template_content = " :<attribute_1>: :<attribute_2>: :<attribute_3>:\n" .
					\ "\n" .
					\ "First pass:  \n" .
       				        \ "Second pass: \n" .
       				        \ "Review: \n" .
       				        \ "Handwritten interview notes: [[file:]]\n" . 
       				        \ "Audio Recording: [[file:]]\n" .
       				        \ "\n" .  
       				        \ "====================\n" . 
					\ "\n" 
 		
		call writefile(split(l:template_content, "\n", 1), g:int_header_template) 
	endif
endfunction

# -----------------------------------------------------------------
# This function finds the current VWQC project parameters
# -----------------------------------------------------------------
def GetVWQCProjectParameters() 
	# Add non-vimwiki wiki definition variables to g:vimwiki_wikilocal_vars
	if !exists("g:vwqc_config_vars_added")
		g:vwqc_config_vars_added = AugmentVimwikiLocalVars()
	endif

	g:wiki_number                        = vimwiki#vars#get_bufferlocal('wiki_nr') 
	g:wiki_number_plus_1                 = g:wiki_number + 1
	g:current_wiki_name                  = "wiki_" .. g:wiki_number_plus_1

	# Get interview column width
	g:text_col_width                     = g:vimwiki_wikilocal_vars[g:wiki_number]['text_col_width']
	g:text_col_width_expression          = "set formatprg=par\\ w" .. g:text_col_width
	
	g:border_offset                      = g:text_col_width + 3
	g:border_offset_less_one	     = g:border_offset - 1
	g:label_offset                       = g:border_offset + 2

	# Get the label regular expression for this wiki
	g:interview_label_regex  = g:vimwiki_wikilocal_vars[g:wiki_number]['interview_label_regex']
	g:tag_search_regex       = g:interview_label_regex .. '\: \d\{4}'
	
	g:project_name           = g:vimwiki_wikilocal_vars[g:wiki_number]['name']

	g:extras_path = substitute(g:vimwiki_wikilocal_vars[g:wiki_number]['path'], '[^\/]\{-}\/$', "", "g") .. g:project_name .. "_extras/"

	g:backup_path = substitute(g:vimwiki_wikilocal_vars[g:wiki_number]['path'], '[^\/]\{-}\/$', "", "g") .. "Backups/"

	# If header template location is explicitly defined then use it, otherwise use default file.
	var has_template = 0
	#has_template = has_key("g:" ..  g:current_wiki_name .. ", 'interview_header_template')\<CR>"
	execute "normal! :let has_template = has_key(g:" ..  g:current_wiki_name .. ", 'interview_header_template')\<CR>"
	if (has_template == 1) 
		execute "normal! :var g:vimwiki_wikilocal_vars[g:wiki_number]['interview_header_template'] = g:" .. g:current_wiki_name .. ".interview_header_template\<CR>" 
		g:int_header_template    = expand(g:vimwiki_wikilocal_vars[g:wiki_number]['interview_header_template'])
	else
		g:int_header_template    = expand(g:extras_path .. "interview_header_template.txt")
	endif
	
	# If subcode dictionary location is explicitly defined then use it, otherwise use default file.
	var has_sub_code_dict = 0
	execute "normal! :let has_sub_code_dict = has_key(g:" .. g:current_wiki_name .. ", 'subcode_dictionary')\<CR>"
	if (has_sub_code_dict == 1)
		execute "normal! :let g:vimwiki_wikilocal_vars[g:wiki_number]['subcode_dictionary'] = g:" .. g:current_wiki_name .. ".subcode_dictionary\<CR>" 
		g:subcode_dictionary_path    = expand(g:vimwiki_wikilocal_vars[g:wiki_number]['subcode_dictionary'])
	else
		g:subcode_dictionary_path    = expand(g:extras_path .. "subcode_dictionary.txt")
	endif

	# If tag summaries directory is explicitly defined use it, otherwise use the default directory
	var has_tag_sum_path = 0
	execute "normal! :has_tag_sum_path = has_key(g:" ..  g:current_wiki_name .. ", 'tag_summaries')\<CR>"
	if (has_tag_sum_path == 1)
		execute "normal! :var g:vimwiki_wikilocal_vars[g:wiki_number]['tag_summaries'] = g:" .. g:current_wiki_name .. ".tag_summaries\<CR>" 
		g:tag_summaries_path       = expand(g:vimwiki_wikilocal_vars[g:wiki_number]['tag_summaries'])
	else
		g:tag_summaries_path       = expand(g:extras_path .. "tag_summaries/")
	endif

	g:glossary_path                    = g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. "Tag Glossary.md"

	var has_coder = 0
	execute "normal! :has_coder = has_key(g:" .. g:current_wiki_name .. ", 'coder_initials')\<CR>"
	if (has_coder)
		execute "normal! :var g:vimwiki_wikilocal_vars[g:wiki_number]['coder_initials'] = g:" .. g:current_wiki_name .. ".coder_initials\<CR>" 
       		g:coder_initials                 = g:vimwiki_wikilocal_vars[g:wiki_number]['coder_initials']
	else
       		g:coder_initials                 = "Unknown coder"
	endif

	g:wiki_extension   	   = g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
	g:target_file_ext  	   = g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
	g:ext_len          	   = len(g:wiki_extension) + 1

	g:last_wiki = g:wiki_number
	
enddef


# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def ParmCheck() 
	if (!exists('g:last_wiki'))
		GetVWQCProjectParameters()
	elseif (vimwiki#vars#get_bufferlocal('wiki_nr') != g:last_wiki)	
		GetVWQCProjectParameters()
	endif
enddef

# -----------------------------------------------------------------
# This function creates a pop-up window with the current project's parameters
# -----------------------------------------------------------------
def ListProjectParameters() 

	ParmCheck()
			
	var base0                = "Base 0 wiki #        " . g:wiki_number
	var base1                = "Base 1 wiki #        " . g:wiki_number + 1
	var list_path            = "Path:                " . g:vimwiki_wikilocal_vars[g:wiki_number]['path']
        var list_ext		   = "Ext:                 " . g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
	var list_regex           = "Label regex:         " . g:interview_label_regex
	var list_text_width      = "Text col width:      " . g:text_col_width
	var list_border_offset   = "Label border col:    " . g:border_offset
	var list_header_template = "Header template:     " . g:int_header_template
	var list_tag_summaries   = "Tag summaries:       " . g:tag_summaries_path
	var list_subcode         = "Sub-code dictionary: " . g:subcode_dictionary_path
	var list_glossary        = "Tag glossary:        " . g:glossary_path
	var list_coder           = "Coder initials:      " . g:coder_initials
 	
	var g:vwqc_proj_parm_list =    ["CURRENT PROJECT CONFIGURATION", " ", 
					 base0                 ,
					 base1                 ,
					 " "                     ,
					 list_path             ,
					 list_ext		  ,
					 list_regex            ,
					 list_text_width       ,
					 list_border_offset    ,
					 list_header_template  ,
					 list_tag_summaries    ,
					 list_subcode          ,
					 list_glossary         ,
					 list_coder            ]
	popup_menu(g:vwqc_proj_parm_list , 
				 { minwidth: 50,
				 maxwidth: 250,
				 pos: 'center',
				 border: [],
				 close: 'click',
				 })

enddef

function DoesFileNameMatchLabelRegex(test_value) 
	if (match(a:test_value, g:interview_label_regex) == 0)
		return 1
	else
		return 0
	end
endfunction

function FormatInterview(label = "default") 

	if (a:label == "default")
		let l:valid_label    = DoesFileNameMatchLabelRegex(expand('%:t:r'))
		let l:proposed_label = expand('%:t:r')
	else
		let l:valid_label = DoesFileNameMatchLabelRegex(a:label)
		let l:proposed_label = a:label
	endif

	if (l:valid_label)
		if (l:proposed_label != expand('%:t:r'))
			let l:file_label_mismatch_warning = l:proposed_label .
				        \ " does not match the " . 
					\ expand('%:t:r') .
					\ " file name."
			call confirm(l:file_label_mismatch_warning, "Got it", 1)
		endif
		call FormatInterviewB(l:proposed_label)
	else
		let l:bad_label_error_message = l:proposed_label . " does not conform to the " .
					\  g:vimwiki_wikilocal_vars[g:wiki_number]['interview_label_regex'] .
					\  " label regular expression from the VWQC configuration. " .
					\  "Interview formatting aborted."	
		call confirm(l:bad_label_error_message, "Got it", 1)
	endif
endfunction

# -----------------------------------------------------------------
# This function formats interview text to use in for Vimwiki interview coding. 
# -----------------------------------------------------------------
function FormatInterviewB(interview_label) 

	call ParmCheck()

	# -----------------------------------------------------------------
	# Add interview header template
	# In this next session the first line resets the formatprg option to match what
	# is set in the wiki configuration. This tells Vim to use the BASH program par 
	# as the text formatter when you type gq.
	# In second line below the whole text is selected (ggVG) then gq is run, 
	# and finally the cursor is reset to the top of the buffer (gg).
	# see http://vimcasts.org/episodes/formatting-text-with-par/ for how par works with vim.		
	# -----------------------------------------------------------------
	execute g:text_col_width_expression
	execute "normal! ggVGgqgg"
	# -----------------------------------------------------------------
	# This next section reformats the AWS Transcribe time stamps to change square 
	# brackets to round ones. Square brackets conflict with Vimwiki links that
	# also use square brackets. setline() writes a line. It uses line (the first
	# argument) with the second argument which is the whole substitute() command.
	# The substitute command starts with the current line (getline(line)) and then
	# finds the [0:14:12] AWS time stamps in square brackets and replaces them with
	# parentheses.
	# -----------------------------------------------------------------
	for line in range(1, line('$'))
		call setline(line, substitute(getline(line), '\[\(\d:\d\d:\d\d\)\]', '\(\1\)', 'g'))
        endfor
	# -----------------------------------------------------------------
	# These next few lines add a fixed end of line at the column specified in the 
	# wiki configuration. The first line turns on virtualedit mode. This allows you to select columns outside the
	# range of your line. The second line just selects the first column. 
	# The third line overwrites the content added in the second line with 
	# pipe symbols. The final line turns virtualedit mode off.
	# -----------------------------------------------------------------
	set virtualedit=all
	execute "normal! gg\<C-v>Gy" . g:border_offset_less_one . "|p"
	execute "normal! gg" . g:border_offset . "|\<C-v>G" . g:border_offset . "|r│"
	set virtualedit=""
	# -----------------------------------------------------------------
	# Reposition cursor at the top of the buffer
	# -----------------------------------------------------------------
	execute "normal! gg"
	# -----------------------------------------------------------------
	# Add labels at the end of the line using the label passed into the 
	# function as an argument.
	# -----------------------------------------------------------------
	for line in range(1, line('$'))
		call cursor(line, 0)
		execute "normal! A " . a:interview_label . "\: \<ESC>"
	endfor
	# -----------------------------------------------------------------
	# Add line numbers to the end of each line and the second
	# column of double pipe symbols
	# -----------------------------------------------------------------
	for line in range(1, line('$'))
		let g:line_number_to_add = printf("%04d │ ", line)
		call setline(line, substitute(getline(line), '$', g:line_number_to_add, 'g'))
        endfor
	# -----------------------------------------------------------------
	# Reposition cursor at the top of the buffer and add header template.
	# -----------------------------------------------------------------
	execute "normal! gg"
	execute "normal! :.-1read " . g:int_header_template . "\<CR>gg"
endfunction

# ------------------------------------------------------------------------------
# Vimwiki creates a list of user wiki config dictionaries in
# g:vimwiki_wikilocal_vars but it only includes the default key-value pairs
# not the extra ones we want to add for our vwqc configurations. This function
# adds the additional configuration key-value pairs. Note
# g:vimwiki_wikilocal_vars will have one extra dictionary for temporary wikis.
# So run this and then set a g:vwqc_config_vars_added flag 
# ------------------------------------------------------------------------------
def AugmentVimwikiLocalVars(): number
	for wiki in range(0, (len(g:vimwiki_list) - 1))
		for key in keys(g:vimwiki_list[wiki])
			if !has_key(g:vimwiki_wikilocal_vars[wiki], key)
				g:vimwiki_wikilocal_vars[wiki][key] = g:vimwiki_list[wiki][key]
			endif
		endfor
	endfor
	return 1
enddef

# -----------------------------------------------------------------
# Provide page specific help based on the buffer nameProvide page specific
# help based on the buffer name
# -----------------------------------------------------------------
function PageHelp() 

	call ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Find the current file name
	
	let g:current_buffer_name = expand('%:t')
	let g:is_interview        = match(g:current_buffer_name, g:interview_label_regex)
	let g:is_annotation       = match(g:current_buffer_name, g:interview_label_regex . ': \d\d\d\d')
	let g:is_summary          = match(g:current_buffer_name, 'Summary ')

	if g:current_buffer_name == "index" . g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		let g:page_help_list = [              
			\        "INDEX HELP PAGE", 
		        \        "The index page is your project home page. You can return to this page by typing <leader>ww in normal mode.",
		        \        "From here you can create new pages for interviews or summary pages.",
		        \        " ",
		        \        "Summary pages, pages that summarize specific tags, must begin with the word \"Summary\". ",
		        \        "Interview pages must be named according to the regular expression (regex) defined in your project parameters. ",
		        \        "Press <leader>lp in normal mode to list project parameters. ",
		        \        " ",
			\        "Click on this window to close it"]
		call DisplayPageHelp()
	elseif g:current_buffer_name == "Attributes" . g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		let g:page_help_list = [              
			\        "ATTRIBUTES HELP PAGE", 
		        \        "The \"Attributes\" page lists the interview attributes which are the tags that appear on the first line of",
		        \        "each interview page. ",
		        \        " ",
		        \        "You can update this page by running the following command in normal mode: ",
		        \        " ",
		        \        ":call Attributes() ",
		        \        " ",
		        \        "These attributes can be sorted by running the Attributes() command with the column number to sort on.",
		        \        "For example, the following command sorts on the third column:",
		        \        " ",
		        \        ":call Attributes(3) ",
		        \        " ",
			\        "Click on this window to close it"]
		call DisplayPageHelp()
	elseif g:current_buffer_name == "Tag List Current" . g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		let g:page_help_list = [              
			\        "TAG LIST CURRENT HELP PAGE", 
		        \        "This lists current project tags. It is generated or updated by pressing F2",
		        \        " ",
			\        "Click on this window to close it"]
		call DisplayPageHelp()
	elseif g:current_buffer_name == "Tag Glossary" . g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		let g:page_help_list = [              
			\        "TAG GLOSSARY HELP PAGE", 
		        \        "Tag definitions can be added here manually, but they are best added by placing the cursor over a valid tag in an ", 
			\        "interview page in normal mode and pressing <leader>df. This will start a dialogue that will allow you to add a tag", 
			\        "definition. When you are finished defining your tag you can press F2 to update the tag list and <leader>gb to ", 
			\	 "return to where you were coding.",
		        \        " ",
			\        "Tag definitions must be inside brace brackets {} and the tag name must be the last word on the first line inside the",
		        \        "brace brackets. The format is flexible but it is recommended that you use the form that is pre-populated when you use",
		        \        "the dialogue that is initiated when you press <leader>df while your cursor is on a tag and you are in normal mode.",
		        \        " ",
			\        "Click on this window to close it"]
		call DisplayPageHelp()
	elseif g:is_annotation == 0
		let g:page_help_list = [              
			\        "ANNOTATION HELP PAGE", 
		        \        "Use F7 to toggle an annotation page open and closed",
		        \        " ",
			\        "Click on this window to close it"]
		call DisplayPageHelp()
	elseif g:is_interview == 0
		let g:page_help_list = [              
			\        "INTERVIEW HELP PAGE", 
		        \        "",
			\        "Interview pages are split into four parts or panes:",
			\        "",
			\        "1) The header",
			\        "2) The interview pane",
			\        "3) The line-label pane",
			\        "4) The coding pane",
			\        "",
			\        "Interview pages are populated by initally pasting the interview text into a blank page ",
			\        "that has been named according to the label regular expression (regex) you used for the",
			\        "project configuration (i.e. /d/d-/w-/w/w/w/w). The pasted interview text is formatted ",
			\        "with the FormatInterview() function. i.e.",
			\        "",
			\        ":call FormatInterview()",
			\        "",
			\        "Annotations are added by pressing F7 on the line where you want to add an annotation.",
			\        "This will open an annotation window on the right-hand side of your screen placing you",
			\        "directly in insert mode. Annotation windows can be closed by pressing F7 again.",
			\        "",
			\        "Tags (codes) are contiguous words beginning with a letter and surrounded by colons.",
			\        "For example :family: or :child:. Each line can have multiple tags, but tags must",
			\        "be separated by a space.",
			\        "",
			\        "Interviews are coded line-wise. This means that each line in a block of code must ",
			\        "be coded, not just the starting and ending lines. Usually, an interview will be ",
			\        "coded from top to bottom. ",
			\        "",
			\        "There are several ways VWQC helps facilitated coding. First, it provides tag ",
			\        "omni-completion. Second, it provides keybindings to fill tags from the bottom of ",
			\        "code block up to the top.",
		        \        "",
		        \        "If you start typing a tag (i.e. a colon followed by one or more characters) and press",
		        \        "F8 (or F9) an omni-completion menu will pop up with a list of tags that begin with the",
		        \        "prefix you just typed. You can use the arrow keys to make your selection and then finish",
		        \        "the tag entry with your closing colon character.",
		        \        "",
		        \        "Block completion looks above the cursor for tag completion candidates. VWQC tries to ",
		        \        "anticipate which tag you want to fill up from your cursor position to make a code block.",
		        \        "If there is only one tag in the contiguous code block above your cursor then VWQC will fill",
		        \        "in that tag. Otherwise you are presented with a menu of tag choices pulled from the first",
		        \        "contiguous code block above the cursor. This menu is generated in one of two modes. The first",
		        \        "mode presents the last tag added to the buffer as the default tag. The default tag can be ",
		        \        "selected by simply pressing enter. The second mode presents the first tag above the cursor as",
		        \        "the default tag. The current tag-fill mode will be indicated in the pop-up menu title. The mode",
		        \        "can be changed with the F4 toggle.",
		        \        "",
		        \        "An annotation associated with a line can be created with the F7 key. This will open an annotation",
		        \        "window to the right of your screen. This annotation window can be closed by pressing F7 again.",
		        \        "If you want to remove an annotation, place your cursor on the line in an interview page where it",
		        \        "is called (not in the annotation page itself) and, in normal mode, press <leader>da and this will",
		        \        "initiate a dialogue that will allow you to delete the annotation.",
		        \        "",
			\        "Click on this window to close it"]
		call DisplayPageHelp()
	elseif g:is_summary == 0
		let g:page_help_list = [              
			\        "SUMMARY HELP PAGE", 
			\	 ":call FullReport(\"<tag>\")           Create report with tagged and annotation content",
			\	 ":call QuotesReport(\"<tag>\")         Create report with just tagged content",
			\	 ":call MetaReport(\"<tag>\")           Create the FullReport with all line metadata",
			\	 ":call VWSReport(\"<string>\")         Create custom search report", 
		        \        " ",
		        \        "Quoted lines can also be recoded within a report. These re-codings",
		        \        "can then be \"gathered\" into a sub-report. Add new codes to the end",
		        \        "of lines. Then place your cursor below the count table near the top of",
		        \        "the report. Run the following command to create the re-coded report.",
		        \        "",
		        \        ":call Gather(\"<tag>\")",
		        \        "",
		        \        "Line-wise coding means that there are usually residual tails and heads",
		        \        "from sentences before and after the text you meant to code or tag. In a ",
		        \        "summary report, you can place your cursor on an interview line and press",
		        \        "<leader>tt to trim the tail of your quote, and <leader>th to trim the head.",
		        \        "If you want to trim both the head and tail you can use <leader>ta.",
		        \        "",
			\        "Click on this window to close it"]
		call DisplayPageHelp()
	endif

endfunction

function DisplayPageHelp() 
	call popup_menu(g:page_help_list , 
			\ #{ minwidth: 50,
			\ maxwidth: 150,
			\ pos: 'center',
			\ border: [],
			\ close: 'click',
			\ })
endfunction

# -----------------------------------------------------------------
#
# -----------------------------------------------------------------
function CreateBackupQuery() 

	call ParmCheck()
	let l:today              = strftime("%Y-%m-%d")
	let l:time_now           = strftime("%H-%M-%S")
	let g:backup_path        = substitute(g:vimwiki_wikilocal_vars[g:wiki_number]['path'], '[^\/]\{-}\/$', "", "g") . "Backups/"
	let g:backup_folder_name = l:today . " at " . l:time_now . " Backup by " . g:coder_initials . "/"
	let g:new_backup_path    = g:backup_path . g:backup_folder_name
	let g:backup_list        = globpath(g:backup_path, '*', 0, 1)

	if len(g:backup_list) > 0
		let g:last_backup        = substitute(g:backup_list[-1], g:backup_path, "", "g")
		let g:backup_message     = "The last backup was: " . g:last_backup . ". Make a new backup now?"
	else
		let g:backup_message     = "No backups found. Make a backup now?"
	endif
			
	call popup_menu(["Yes", "No"], #{
		\ title:    g:backup_message   ,
		\ callback: 'CreateBackup'  , 
		\ highlight: 'Question'       ,
		\ border:     []              ,
		\ close:      'click'         , 
		\ padding:    [0,1,0,1],
		\ })
endfunction

# -----------------------------------------------------------------
#
# -----------------------------------------------------------------
function CreateBackup(id, result) 
	if a:result == 1
		#Save current buffer so it doesn't matter if we delete copied
		#swap files.
		execute "normal! :w\<CR>"
		call mkdir(g:new_backup_path, "p")
		let g:copy_command  = 'cp -R "' . g:vimwiki_wikilocal_vars[g:wiki_number]['path'] . '" "' . g:new_backup_path . '"'
		let g:clean_up_swo = 'rm -f "' . g:new_backup_path . '"' . '.*.swo'
		let g:clean_up_swp = 'rm -f "' . g:new_backup_path . '"' . '.*.swp'
		let g:clean_up_swn = 'rm -f "' . g:new_backup_path . '"' . '.*.swn'
		call system(g:copy_command)
		call system(g:clean_up_swo)
		call system(g:clean_up_swp)
		call system(g:clean_up_swn)
		let l:backup_message 	   = "A new back up has been created at: " . g:new_backup_path
	else
		let l:backup_message       = "Backup not created."		
	endif
	
	call confirm(l:backup_message,  "OK", 1)
	
endfunction

# -----------------------------------------------------------------
# --------------------------- NAVIGATION  -------------------------
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# One of three annotation functions. This first one opens an annotation window.
# If it is a new window it names it using the label from line from which it is
# called, adds a title label and the coders initials.
# -----------------------------------------------------------------
function Annotation() 
	
	call ParmCheck()

	# -----------------------------------------------------------------
	#  Find the tags on the line this function is called from.
	# -----------------------------------------------------------------
	let g:list_of_tags_on_line = ""
	let g:is_tag_on_line = 1
	let g:current_line = line(".")
	execute "normal! 0"
	# -----------------------------------------------------------------
	# Loop until no more tags are found on the line.
	# -----------------------------------------------------------------
	while (g:is_tag_on_line == 1)
		# --------------------------------------------------
		# Search for a tag without going past the end of the file.
		# --------------------------------------------------
		let g:match_line = search(':\a.\{-}:', "W")
		# --------------------------------------------------
		# If we found a tag (ie. The search function doesn't
		# return a zero) and that tag is found on the current line
		# then add the tag to our list. Note search will move the
		# cursor to the first character of the match.
		# --------------------------------------------------
		if (g:match_line == g:current_line)
			# -------------------------------------------
			# Copy the tag we found and move the cursor one
			# character past the tag. Then add that tag to the
			# list of tags we're building.
			# -------------------------------------------
			execute "normal! vf:yeel"
			let g:this_tag = @@
			let g:list_of_tags_on_line = g:list_of_tags_on_line . g:this_tag . " "
		else
			# No more tags
			let g:is_tag_on_line = 0
		endif 
	endwhile	
	# -----------------------------------------------------------------
	# Move cursor back to the start of current_line because the search
	# function may have moved the cursor beyond current_line
	# -----------------------------------------------------------------
	call cursor(g:current_line, 0)
	execute "normal! 0"
	# -----------------------------------------------------------------
	# Initialize variables and move cursor to the beginning of the line.
	# -----------------------------------------------------------------
	let g:match_line = 0
	let g:match_col = 0
	# -----------------------------------------------------------------
	# Search for the label - number pair on the line. searchpos() 
	# returns a list with the line and column numbers of the cursor
	# position of the first character in the match. searchpos() with
	# the arguments we supplied will move the cursor to the first
	# character of match we found. So because we started in column 1
	# if the column remains at 1 we know we didn't find a match.
	# -----------------------------------------------------------------
	let g:tag_search_regex = g:interview_label_regex . '\: \d\{4}'
	let g:tag_search = searchpos(g:tag_search_regex)
	let g:match_line = g:tag_search[0]
	let g:match_col  = virtcol('.')
	# -----------------------------------------------------------------
	# Now we have to decide what to do with the result based on where
	# the cursor ended up. The first thing we test is whether the match
	# line is the same as the current line. This may not be true if it 
	# had to go down one or more lines to find a match. If its true we
	# execute the first part of the if statement. Otherwise we print an 
	# error message and reposition the cursor at the beginning of the 
	# line where we started.
	# -----------------------------------------------------------------
	if g:current_line == g:match_line
		# ------------------------------------------------------------------
		#  Figure out how wide we can make the annotation window
		# ------------------------------------------------------------------
		let g:current_window_width = winwidth('%')
		let g:annotation_window_width = g:current_window_width - g:border_offset - 45
		if g:annotation_window_width < 30
			let g:annotation_window_width = 30
		elseif g:annotation_window_width > 80
			let g:annotation_window_width = 80
		endif
		# ------------------------------------------------------------------
		#  Figure out which version of Vim or NeoVim we're running.
		#  Older versions have a different vsplit behavior. The first
		#  test is for Vim and the second for NeoVim. has() returns a
		#  1 for true or 0 for false.
		# ------------------------------------------------------------------
		if has('nvim') && has('patch-0-6-0')
			let g:new_vsplit_behaviour = 1
		elseif has('patch-8.2.3832')
			let g:new_vsplit_behaviour = 1
		else
			let g:new_vsplit_behaviour = 0
		endif
		# -----------------------------------------------------------------
		# Test to see if the match starts at g:label_offset or 
		# g:label_offset + 1. g:label_offset refers to the column
		# that we that we formatted the label to start at.
	 	# If there is an existing link to an annotation page the 
		# link will be surrounded by Vimwiki's square bracket link 
		# notation []. The opening bracket will cause the match to 
		# be bumped over to the right by 1 column, hence the match
		# will start at g:label_offset + 1.
		# -----------------------------------------------------------------
		if g:match_col == g:label_offset		
			# -----------------------------------------------------------------
			# Re-find the label-number pair and yank it. The next
			# line builds the Vimwiki link. There must be a Vimwiki
			# plug command that does this but I couldn't figure it 
			# out. Then we follow the link to a new page. The final 
			# two lines add the title to the new page and position 
			# the cursor at the bottom of the page.
			# -----------------------------------------------------------------
			execute "normal! " . '0/' . g:interview_label_regex . '\:\s\{1}\d\{4}' . "\<CR>" . 'vf│hhy'
			execute "normal! gvc[]\<ESC>F[plli()\<ESC>\"\"P\<ESC>" 
			execute "normal \<Plug>VimwikiVSplitLink"
			if g:new_vsplit_behaviour 
				execute "normal! \<C-W>x\<C-W>l:vertical resize " . g:annotation_window_width . "\<CR>"
			else
				execute "normal! \<C-W>x\<C-W>l:vertical resize " . g:annotation_window_width . "\<CR>"
			endif
			put =expand('%:t')
			execute "normal! 0kdd/.md\<CR>xxxI:\<ESC>2o\<ESC>"
			let g:current_time = strftime("%Y-%m-%d %H\:%M")
		        execute "normal! i[" . g:current_time . "] " . g:list_of_tags_on_line . "// \:" . g:coder_initials . "\:  \<ESC>"
			startinsert 
		elseif g:match_col == (g:label_offset + 1)
			# -----------------------------------------------------------------
			# Re-find the link, but don't yank it. This places the 
			# cursor on the first character of the match. The next
			# line follows the link to the page and the final line 
			# places the cursor at the bottom of the annotation 
			# page.
			# -----------------------------------------------------------------
			execute "normal! " . '0/' . g:interview_label_regex . '\:\s\{1}\d\{4}' . "\<CR>"
			execute "normal \<Plug>VimwikiVSplitLink"
			if g:new_vsplit_behaviour 
				execute "normal! \<C-w>x\<C-W>l:vertical resize " . g:annotation_window_width . "\<CR>"
			else
				execute "normal! \<C-W>x\<C-W>l:vertical resize " . g:annotation_window_width . "\<CR>"
			endif
			execute "normal! Go\<ESC>V?.\<CR>jd2o\<ESC>"
			let g:current_time = strftime("%Y-%m-%d %H\:%M")
		        execute "normal! i[" . g:current_time . "] " . g:list_of_tags_on_line . "// \:" . g:coder_initials . "\:  \<ESC>"
			startinsert
		else
			echo "Something is not right here."		
		endif
	else
		echo "No match found on this line"
		call cursor(g:current_line, 0)
	endif
endfunction

# -----------------------------------------------------------------
# This function exits an annotation window and resizes remaining windows
# -----------------------------------------------------------------
function ExitAnnotation() 
	
	call ParmCheck()

	# -----------------------------------------------------------------
	# Remove blank lines from the bottom of the annotation, and copy the
	# remaining bottom line to test_line 
	# -----------------------------------------------------------------
	execute "normal! Go\<ESC>V?.\<CR>jdVy\<ESC>"
	let g:test_line = @@
	# -----------------------------------------------------------------
	# Build a regex that looks for the coder tag at the beginning of the line and
	# then only white space to the carriage return character.
	# -----------------------------------------------------------------
	let g:find_coder_tag_regex = '\v:' . g:coder_initials . ':\s*\n'
	let g:is_orphaned_tag = match(g:test_line, g:find_coder_tag_regex) 
	# -----------------------------------------------------------------
	# If you don't find anything following the coder tag, ie there is no
	# annotation following, delete the label info generated for this
	# annotation.
	# -----------------------------------------------------------------
	if (g:is_orphaned_tag != -1)
		execute "normal! Vkdd"
	endif
	# -----------------------------------------------------------------
	# Close annotation window and resize remaining windows. Place the
	# cursor at the end of the line it returns to.
	# -----------------------------------------------------------------
	execute "normal! :wq\<CR>\<C-W>h\<C-W>h:vertical resize 60\<CR>\<C-W>l"
	execute "normal! " . ':s/\s*$//' . "\<CR>A \<ESC>"
endfunction

# -----------------------------------------------------------------
# This function determines what kind of buffer the cursor is in (annotation or
# interview) and decides whether to call Annotation() or ExitAnnotation()
# -----------------------------------------------------------------
function AnnotationToggle() 

	call ParmCheck()

	# -----------------------------------------------------------------
	# Initialize buffer type variables
	# -----------------------------------------------------------------
	let g:is_interview  = 0
	let g:is_annotation = 0
	let g:is_summary    = 0

	let g:buffer_name      = expand('%:t')
	let g:where_ext_starts = strridx(g:buffer_name, g:wiki_extension)
	let g:buffer_name      = g:buffer_name[0 :(g:where_ext_starts - 1)]
	# -----------------------------------------------------------------
	# Check to see if it is a Summary file. It it is nothing happens.
	# -----------------------------------------------------------------
	let g:summary_search_match_loc = match(g:buffer_name, "Summary")
	if (g:summary_search_match_loc == -1)	# not found
		let g:is_summary = 0		# FALSE
	else
		let g:is_summary = 1		# TRUE
	endif
	# -----------------------------------------------------------------
	# Check to see if the current search result buffer is
	# an annotation file. If it is ExitAnnotation() is called.
	# -----------------------------------------------------------------
	let g:pos_of_4_digit_number = match(g:buffer_name, ' \d\{4}')
	if (g:pos_of_4_digit_number == -1)      " not found
		let g:is_annotation = 0		# FALSE
	else
		let g:is_annotation = 1		# TRUE
		call ExitAnnotation()		
	endif
	# -----------------------------------------------------------------
	# Check to see if the current search result buffer is
	# from an interview file. If it is Annotation() is called.
	# -----------------------------------------------------------------
	if (g:is_annotation == 1) || (g:is_summary == 1)
		let g:is_interview = 0		# FALSE
	else
		let g:is_interview = 1		# TRUE
		call Annotation()
	endif
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function DeleteAnnotation() 
	
	call ParmCheck()

	# ------------------------------------------------------------------
	#  Figure out which version of Vim or NeoVim we're running.
	#  Older versions have a different vsplit behavior. The first
	#  test is for Vim and the second for NeoVim. has() returns a
	#  1 for true or 0 for false.
	# ------------------------------------------------------------------
	if has('nvim') && has('patch-0-6-0')
		let g:new_vsplit_behaviour = 1
	elseif has('patch-8.2.3832')
		let g:new_vsplit_behaviour = 1
	else
		let g:new_vsplit_behaviour = 0
	endif
	# -----------------------------------------------------------------
	#  Find the tags on the line this function is called from.
	# -----------------------------------------------------------------
	let g:is_tag_on_line = 1
	let g:current_line = line(".")
	execute "normal! 0"
	# -----------------------------------------------------------------
	# Search for the label - number pair on the line. searchpos() 
	# returns a list with the line and column numbers of the cursor
	# position of the first character in the match. searchpos() with
	# the arguments we supplied will move the cursor to the first
	# character of match we found. So because we started in column 1
	# if the column remains at 1 we know we didn't find a match.
	# -----------------------------------------------------------------
	let g:tag_search_regex = g:interview_label_regex . '\: \d\{4}'
	let g:tag_search = searchpos(g:tag_search_regex)
	let g:match_line = g:tag_search[0]
	let g:match_col  = virtcol('.')
	# -----------------------------------------------------------------
	# Now we have to decide what to do with the result based on where
	# the cursor ended up. The first thing we test is whether the match
	# line is the same as the current line. This may not be true if it 
	# had to go down one or more lines to find a match. If its true we
	# execute the first part of the if statement. Otherwise we print an 
	# error message and reposition the cursor at the beginning of the 
	# line where we started.
	# -----------------------------------------------------------------
	if g:current_line == g:match_line
		# -----------------------------------------------------------------
		# Test to see if the match starts at g:label_offset or 
		# g:label_offset + 1. g:label_offset refers to the column
		# that we that we formatted the label to start at.
	 	# If there is an existing link to an annotation page the 
		# link will be surrounded by Vimwiki's square bracket link 
		# notation []. The opening bracket will cause the match to 
		# be bumped over to the right by 1 column, hence the match
		# will start at g:label_offset + 1.
		# -----------------------------------------------------------------
		if g:match_col == g:label_offset		
			call confirm("No annotation link found on this line.", "OK", 1)
		elseif g:match_col == (g:label_offset + 1)
			# -----------------------------------------------------------------
			# Re-find the link, but don't yank it. This places the 
			# cursor on the first character of the match. The next
			# line follows the link to the page.
			# -----------------------------------------------------------------
			execute "normal! " . '0/' . g:interview_label_regex . '\:\s\{1}\d\{4}' . "\<CR>"
			execute "normal \<Plug>VimwikiVSplitLink"
			if g:new_vsplit_behaviour 
				execute "normal! \<C-W>x\<C-W>l:vertical resize " . g:annotation_window_width . "\<CR>"
			else
				execute "normal! \<C-W>x\<C-W>l:vertical resize " . g:annotation_window_width . "\<CR>" 
			endif
			let g:candidate_delete_buffer = bufnr("%")
			execute "normal \<Plug>VimwikiDeleteFile"
			# if bufwinnr() < 0 then the buffer doesn't exist.
			if (bufwinnr(g:candidate_delete_buffer) < 0)
				execute "normal! :q\<CR>"
				execute "normal! " . g:match_line . "G"
				let g:col_to_jump_to = g:match_col - 1
				set virtualedit=all
				# the lh at the end should probably be \|
				execute "normal! 0" . g:col_to_jump_to . "lh"
				set virtualedit=""
				execute "normal! xf]vf)d"
				call confirm("Annotation deleted.", "Got it", 1)
			else
				execute "normal! :q\<CR>"
				call confirm("Annotation retained.", "Got it", 1)
			endif
		else
			echo "Something is not right here."		
		endif
	else
		echo "No match found on this line"
		call cursor(g:current_line, 0)
	endif
endfunction

# -----------------------------------------------------------------
# Finds a label-line number pair in a Summary buffer and uses that to to to
# that location in an interview buffer.
# -----------------------------------------------------------------
function GoToReference() 
	
	call ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Find target file name.
	# -----------------------------------------------------------------
	execute "normal! 0/" . g:interview_label_regex . ':\s\d\{4}' . "\<CR>" . 'vf:hy'
	let g:target_file = @@
	let g:target_file = g:target_file . g:target_file_ext
	# -----------------------------------------------------------------
	# Find target line number "
	# -----------------------------------------------------------------
	execute "normal! `<"
	execute "normal! " . '/\d\{4}' . "\<CR>"
	execute "normal! viwy"
	let g:target_line = @@
	# -----------------------------------------------------------------
	# Use Z mark to know how to get back
	# -----------------------------------------------------------------
	execute "normal! mZ"
	# -----------------------------------------------------------------
	# Go to target file
	# -----------------------------------------------------------------
	execute "normal :e " . g:target_file . "\<CR>"
	execute "normal! gg"
	# -----------------------------------------------------------------
	# Find line number and center on page
	# -----------------------------------------------------------------
	execute "normal! gg"
	call search(g:target_line)
	execute "normal! zz"
endfunction

# -----------------------------------------------------------------
# Returns to the place called by GoToReference().
# -----------------------------------------------------------------
function GoBackFromReference() 
	execute "normal! `Zzz"
endfunction

# -----------------------------------------------------------------
# ---------------------------- REPORTS ----------------------------
# -----------------------------------------------------------------

function FullReport(search_term)
	call Report(a:search_term, "full", "FullReport", "no meta")
endfunction

function AnnotationsReport(search_term)
	call Report(a:search_term, "annotations", "AnnotationReport", "no meta") 
endfunction

function QuotesReport(search_term)
	call Report(a:search_term,  "quotes", "QuotesReport", "no meta") 
endfunction

function MetaReport(search_term)
	call Report(a:search_term,  "meta", "MetaReport", "meta") 
endfunction

function VWSReport(search_term)
	call Report(a:search_term, "VWS", "VWSReport", "meta") 
endfunction

# -----------------------------------------------------------------
# This function produces summary reports for all tags defined in the 
# tag glossary.
# -----------------------------------------------------------------
function AllSummariesFull() 

	call ParmCheck()
	execute "normal! :cd %:p:h\<CR>"
	
	let g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	let g:tags_list_length = len(g:in_both_lists)

	if g:tags_list_length > 0
		call GenSummaryLists("full")
	endif
	
	if (g:tags_generated == 1) && (g:tags_list_length > 0)
		call popup_menu(["No, abort", "Yes, generate summary reports"], #{
			\ title:    "Running this function will erase older \"Full\" versions of these reports. Do you want to continue?"   ,
			\ callback: 'AllSummariesGenReportsFull'  , 
			\ highlight: 'Question'       ,
			\ border:     []              ,
			\ close:      'click'         , 
			\ padding:    [0,1,0,1],
			\ })
	else
		call confirm("Either tags have not been generate for this session or there are no tags to create reports for.",  "OK", 1)

	endif
	
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function AllSummariesGenReportsFull(id, result)
	if a:result == 2
		execute "normal! :delmarks Q\<CR>mQ"
		call confirm("Generating these summary reports will likely take a long time.",  "OK", 1)
		for l:index in range(0, g:tags_list_length - 1)
			execute "normal! :e " . g:summary_file_list[l:index] . "\<CR>"
			call FullReport(g:in_both_lists[l:index])
		endfor
		execute "normal! `Q"
		put =g:summary_link_list
		execute "normal! `Q"
	endif
endfunction

# -----------------------------------------------------------------
# This function produces summary reports for all tags defined in the 
# tag glossary.
# -----------------------------------------------------------------
function AllSummariesQuotes() 

	call ParmCheck()
	execute "normal! :cd %:p:h\<CR>"
	
	let g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	let g:tags_list_length = len(g:in_both_lists)

	if g:tags_list_length > 0
		call GenSummaryLists("quotes")
	endif
	
	if (g:tags_generated == 1) && (g:tags_list_length > 0)
		call popup_menu(["No, abort", "Yes, generate summary reports"], #{
			\ title:    "Running this function will erase older \"Quotes\" versions of these reports. Do you want to continue?"   ,
			\ callback: 'AllSummariesGenReportsQuotes'  , 
			\ highlight: 'Question'       ,
			\ border:     []              ,
			\ close:      'click'         , 
			\ padding:    [0,1,0,1],
			\ })
	else
		call confirm("Either tags have not been generate for this session or there are no tags to create reports for.",  "OK", 1)

	endif
	
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function AllSummariesGenReportsQuotes(id, result)
	if a:result == 2
		execute "normal! :delmarks Q\<CR>mQ"
		call confirm("Generating these summary reports will likely take a long time.",  "OK", 1)
		for l:index in range(0, g:tags_list_length - 1)
			execute "normal! :e " . g:summary_file_list[l:index] . "\<CR>"
			call QuotesReport(g:in_both_lists[l:index])
		endfor
		execute "normal! `Q"
		put =g:summary_link_list
		execute "normal! `Q"
	endif
endfunction

# -----------------------------------------------------------------
# Generated list of file names from the g:in_both_lists list.
# -----------------------------------------------------------------
function GenSummaryLists(type) 
	let g:summary_file_list = []
	let g:summary_link_list = []
	for l:tag_index in range(0, (len(g:in_both_lists) - 1))
		let l:file_name = "Summary " . g:in_both_lists[l:tag_index] . " " . a:type . " batch" . g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		let l:link_name = "[Summary " . g:in_both_lists[l:tag_index] . " " . a:type . " batch](Summary " . g:in_both_lists[l:tag_index] . " " . a:type . " batch)"
		let g:summary_file_list = g:summary_file_list + [l:file_name]
		let g:summary_link_list = g:summary_link_list + [l:link_name]
	endfor
endfunction

# -----------------------------------------------------------------
# This builds a formatted report for the tag specified as the search_term
# argument.
# -----------------------------------------------------------------
function Gather(search_term) 
	
	call ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	let g:tag_search_regex      = g:interview_label_regex . '\: \d\{4}'
	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Set a mark R in the current buffer which is the buffer where your
	# report will appear.
	# -----------------------------------------------------------------
	execute "normal! :delmarks R\<CR>"
	execute "normal! mR"
	let g:search_term = ":" . a:search_term . ":"

	let @s = "# BEGIN THEME: " . a:search_term .  "\n\n"

	while search(g:search_term, "W")
		if match(getline("."), g:tag_search_regex) > 0
			let @s = @s . getline(".") . "\n\n"
		else
			execute "normal! ?{\<CR>V/}\<CR>y"
			let @s = @s . @@ . "\n"
			execute "normal! `>"
		endif	
	endwhile

	let @s = @s . "# END THEME: " . a:search_term .  "\n\n"
	execute "normal! `R\"sp"
endfunction

function Report(search_term, report_type = "full", function_name = "FullReport", meta = "no meta") 
	call ParmCheck()
	
	let g:tag_summary_file = g:tag_summaries_path . a:search_term . ".csv"
	# Change the pwd to that of the current wiki.
	execute "normal! :cd %:p:h\<CR>"

	# Set a mark R in the current buffer which is the buffer where your
	# report will appear.
	execute "normal! :delmarks R\<CR>"
	execute "normal! ggmR"

	# Set tag summary file path
	let g:tag_summary_file      = g:tag_summaries_path . a:search_term . ".csv"

	# Call VimwikiSearchTags against the a:search_term argument.
	# Put the result in loc_list which is a list of location list
	# dictionaries that we'll process.
	if (a:report_type == "VWS")
		let g:escaped_search_term = escape(a:search_term, ' \')
		execute "normal! :VimwikiSearch /" . a:search_term . "/\<CR>"
	else
		execute "normal! :VimwikiSearchTags " . a:search_term . "\<CR>"
	endif

	let g:loc_list = getloclist(0)

	let g:escaped_search_term = escape(a:search_term, ' \')
	execute "normal! :VimwikiSearch /" . a:search_term . "/\<CR>"

	# Initialize values the will be used in the for loop below. The
	# summary is going to be aggregated in the s register.
	let @s                               = "\n"
	let @t				     = "| No. | Interview | Blocks | Lines | Annos |\n|-------:|-------|------:|------:|------:|\n"
	let @u                               = ""

	let g:quote_dict =  {}
	let g:anno_dict = {}

	let g:last_line              = 0
	let g:last_int_line 	     = 0
	let g:last_int_name 	     = 0
	let g:last_block_num         = 0
	let g:anno_int_name          = ""
	let g:last_anno_int_name     = ""
	let g:current_anno_int_name  = ""
	let g:block_count            = 0
	let g:block_line_count       = 0
	let g:cross_codes            = []
	
	# Get the number of search results.
	let g:num_search_results = len(g:loc_list)
	
	# Go through all the location list search results and build the
	# interview line and annotation dictionaries. 
	for g:ll_num in range(0, g:num_search_results - 1)
		let g:current_buf_name    = bufname(g:loc_list[g:ll_num]['bufnr'])[0:-g:ext_len]
		let g:ll_bufnr            = g:loc_list[g:ll_num]['bufnr']
		let g:line_text           = g:loc_list[g:ll_num]['text']
		let g:line_text_less_meta = RemoveMetadata(g:line_text)
		let g:current_buf_type    = FindBufferType(g:current_buf_name)
		if (g:current_buf_type == "Interview")
			let g:current_int_line_num = GetInterviewLineInfo(g:line_text)
			call PopulateQuoteLineList()
			let g:last_int_line_num  = g:current_int_line_num
			let g:last_int_name      = g:current_buf_name
		elseif (g:current_buf_type == "Annotation")
			call PopulateAnnoLineList(g:current_buf_type)
			let g:last_anno_int_name  = g:current_anno_int_name
			let g:last_anno_buf_name  = g:current_buf_name
		endif
	endfor

	let g:int_keys          = sort(keys(g:quote_dict))
	let g:anno_keys         = sort(keys(g:anno_dict))
	let g:int_and_anno_keys = sort(g:int_keys + g:anno_keys)
	

	let l:combined_list_len = len(g:int_and_anno_keys)

	let g:unique_keys = filter(copy(g:int_and_anno_keys), 'index(g:int_and_anno_keys, v:val, v:key+1) == -1')
	
	if (a:report_type == "full") || (a:report_type == "meta") || (a:report_type == "VWS")
		let g:interview_list = g:unique_keys
		for g:int_index in range(0, len(g:interview_list) - 1)
			call ProcessInterviewTitle(g:interview_list[g:int_index])
			call ProcessInterviewLines(a:meta, a:report_type, a:search_term)
			call ProcessAnnotationLines()
		endfor
		call writefile(split(@u, "\n", 1), g:tag_summary_file)
	elseif (a:report_type == "annotations")
		let g:interview_list = g:anno_keys
		for g:int_index in range(0, len(g:interview_list) - 1)
			call ProcessInterviewTitle(g:interview_list[g:int_index])
			call ProcessAnnotationLines()
		endfor
	elseif (a:report_type == "quotes")
		let g:interview_list = g:int_keys
		for g:int_index in range(0, len(g:interview_list) - 1)
			call ProcessInterviewTitle(g:int_keys[g:int_index])
			call ProcessInterviewLines(a:meta,  a:report_type, a:search_term )
		endfor
		call writefile([@u], g:tag_summary_file)
	endif

	let @t = "| No. | Interview | Blocks | Lines | Lines/Block | Annos |\n|-------:|-------|------:|------:|------:|\n"
	let g:total_blocks      = 0
	let g:total_lines       = 0
	let g:total_annos       = 0
	for g:int_index in range(0, len(g:unique_keys) - 1)
		call CreateSummaryCountTableLine()
	endfor 
	let g:total_lines_per_block = printf("%.1f", str2float(g:total_lines) / str2float(g:total_blocks))
	let @t = @t . "|-------:|-------|------:|------:|------:|------:|\n"
	let @t = @t . "| Totals: |  | " . g:total_blocks .  " | " . g:total_lines . " | " . g:total_lines_per_block . " | " . g:total_annos . " |\n"
	 
	#  Write summary line to t register for last interview
	call AddReportHeader(a:function_name, a:search_term)

	# Clear old material from the buffer
	execute "normal! `RggVGd"
	
	# Paste the s register into the buffer. The s register has the quotes
	# we've been copying.
	execute "normal! \"tPgga\<ESC>"
	execute "normal! gg\"qPGo"
	execute "normal! \"sp"
	execute "normal! ggdd"
endfunction

#this code is in Attributes(). Need substitute a call to this function
#instead.
# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function GetInterviewFileList() 
	execute "normal! :cd %:p:h\<CR>"
	# get a list of all the files and directories in the pwd. Note the
	# fourth argument that is 1 makes it return a list. The first argument
	# '.' means the current directory and the second argument '*' means
	# all.
	let l:file_list_all = globpath('.', '*', 0, 1)
	# build regex we'll use just to find our interview files. 
	let l:file_regex = g:interview_label_regex . '.md'
	#  cull the list for just those files that are interview files. the
	#  match is at position 2 because the globpath function prefixes
	#  filenames with ./ which occupies positions 0 and 1.
	let g:interview_list = []
	for list_item in range(0, (len(l:file_list_all) - 1))
		if (match(l:file_list_all[list_item], l:file_regex) == 2) 
			# strip off the leading ./
			let l:file_to_add = l:file_list_all[list_item][2:]
			let g:interview_list = g:interview_list + [l:file_to_add]
		endif
	endfor
	#return l:interview_list
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function CrawlBufferTags(interview, interview_name) 
	# This is essentially the TagLinterFunction that copies the results to
	# g:tags_list
	let l:start_line = 2
	let l:end_line   = line('$')
	# move through each line testing for tags and removing duplicate tags
	# on each line
	execute "normal 2G"
	
	let g:tags_on_line = []
	for line in range(l:start_line, l:end_line)
		# search() returns 0 if match not found
		let g:tag_test = search(':\a.\{-}:', '', line("."))
		if (g:tag_test != 0)
			# Copy found tag
			execute "normal! viWy"
			let g:tags_on_line = g:tags_on_line + [@@]
			let g:tag_test = search(':\a.\{-}:', '', line("."))
			while (g:tag_test != 0)
				execute "normal! viWy"
				let l:tag_being_considered = @@
				let g:have_tag = 0
				# loop to see if we already have this tag
				for l:tag in range(0, len(g:tags_on_line) - 1 )
					if (l:tag_being_considered == g:tags_on_line[l:tag])
						let g:have_tag = 1
					endif
				endfor
				# if we have the tag, delete it
				if g:have_tag 
					execute "normal! gvx"
				else
					let g:tags_on_line = g:tags_on_line + [@@]
				endif
				let g:tag_test = search(':\a.\{-}:', '', line("."))
			endwhile
		endif
		# Add tags found on line to g:tags_list
		for tag_index in range(0, len(g:tags_on_line) - 1)
			let g:tags_list = g:tags_list + [[a:interview_name, line, g:tags_on_line[tag_index]]]
		endfor
		# Go to start of next line
		execute "normal! j0"
		let g:tags_on_line = []
	endfor	
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function CalcInterviewTagCrosstabs(tags_list, unique_tags, interview_list, ext_length) 
	#build the data structure that will hold the interview-tag crosstabs
	let g:tag_count_dict       = {}
	let g:initial_tag_dict     = {}

	for index in range(0, (len(a:interview_list) - 1)) 
		let a:interview_list[index] = a:interview_list[index][:a:ext_length]
	endfor
	# The initial_tag_dict is a dictionary the unique tags with values of four-element lists. Where
	# element 
	# 0 is the tag count
	# 1 is the block count
	# 2 is the space to keep track of the last tag's interview line number, 
	# 3 is a boolean (represented by a 0 or 1 indicating if you're
	# tracking a tag block or not. 
	
	# Create an initialized inital_tag_dict 
	
	#for tag_key in sort(keys(a:unique_tags))
	# The problem is that the tag names are not being assigned as keys.
	# Rather the key is a number.
	for index in range(0, (len(a:unique_tags) - 1)) 
		let g:initial_tag_dict[a:unique_tags[index]] = [0,0,0,0]
	endfor
	#For create an interview dict with a the values for each key being a
	# copy of the initial_tag_dict
	for interview in range(0, (len(a:interview_list) - 1))
		let g:tag_count_dict[a:interview_list[interview]] = deepcopy(g:initial_tag_dict)
	endfor

	for index in range(0, len(g:tags_list) - 1)
		# Increment the tag count for this tag
		let g:tag_count_dict[a:tags_list[index][0]][a:tags_list[index][2]][0] = g:tag_count_dict[a:tags_list[index][0]][a:tags_list[index][2]][0] + 1
		# if tags_list row number minus row number minus the
		# correspondent tag tracking number isn't 1, i.e. contiguous
		if ((a:tags_list[index][1] - g:tag_count_dict[a:tags_list[index][0]][a:tags_list[index][2]][2]) != 1)
			#Mark that you've entered a block 
			let g:tag_count_dict[a:tags_list[index][0]][a:tags_list[index][2]][3] = 1
			#Increment the block counter for this tag
			let g:tag_count_dict[a:tags_list[index][0]][a:tags_list[index][2]][1] = g:tag_count_dict[a:tags_list[index][0]][a:tags_list[index][2]][1] + 1
		else
			# Reset the block counter because you're
			# inside a block now. There is no need to
			# increment the block counter.
			let g:tag_count_dict[a:tags_list[index][0]][a:tags_list[index][2]][3] = 0
		endif
		# Set the last line for this kind of tag equal to the line of the tag we've been considering in this loop.
		let g:tag_count_dict[a:tags_list[index][0]][a:tags_list[index][2]][2] = a:tags_list[index][1]
	endfor
	return g:tag_count_dict
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function FindLargestTagAndBlockCounts(tag_cross, unique_tags, interview_list, ext_length) 
	let l:largest_tag_count   = 0
	let l:largest_block_count = 0

	for interview_index in range(0, (len(a:interview_list) - 1))
		for tag_index in range(0, (len(a:unique_tags) - 1)) 
			if (a:tag_cross[a:interview_list[interview_index]][a:unique_tags[tag_index]][0] > l:largest_tag_count)
				let l:largest_tag_count = a:tag_cross[a:interview_list[interview_index]][a:unique_tags[tag_index]][0]
			endif
			if (a:tag_cross[a:interview_list[interview_index]][a:unique_tags[tag_index]][1]  > l:largest_block_count)
				let l:largest_block_count =a:tag_cross[a:interview_list[interview_index]][a:unique_tags[tag_index]][1]
			endif
		endfor
	endfor
	return [l:largest_tag_count, l:largest_block_count]
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function PrintInterviewTagSummary(tag_cross, interview, unique_tags) 
	let l:total_tags   = 0
	let l:total_blocks = 0

	let l:report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Interview " . a:interview . " tag summary last updated at " . l:report_update_time . "**\n\n"
	execute "normal! i|Tag|Tag Count|Block Count|Average Block Size| \n"
	execute "normal! ki\<ESC>j"
	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"

	for tag_index in range(0, (len(a:unique_tags) - 1))
		let l:ave_block_size = printf("%.1f", str2float(a:tag_cross[a:interview][a:unique_tags[tag_index]][0]) / str2float(a:tag_cross[a:interview][a:unique_tags[tag_index]][1]))
		execute "normal! i|" . a:unique_tags[tag_index] . "|" . 
					\ a:tag_cross[a:interview][a:unique_tags[tag_index]][0] . "|" . 
					\ a:tag_cross[a:interview][a:unique_tags[tag_index]][1] . "|" .
					\ l:ave_block_size         . "|\n"
		execute "normal! ki\<ESC>j"
		let l:total_tags   = l:total_tags   + a:tag_cross[a:interview][a:unique_tags[tag_index]][0]
		let l:total_blocks = l:total_blocks + a:tag_cross[a:interview][a:unique_tags[tag_index]][1]
	endfor

	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"
	let l:ave_total_blocks_size = printf("%.1f", str2float(l:total_tags) / str2float(l:total_blocks))
	execute "normal! i| Totals |" . 
				\ l:total_tags             . "|" . 
				\ l:total_blocks           . "|" .
				\ l:ave_total_blocks_size  . "|\n\n"
	#execute "normal! 2ki\<ESC>2j"
	execute "normal! 2ki\<ESC>2j"
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function PrintTagInterviewSummary(tag_cross, tag, interview_list) 
	let l:total_tags   = 0
	let l:total_blocks = 0

	let l:report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Tag " . a:tag . " tag summary last updated at " . l:report_update_time . "**\n\n"
	execute "normal! i|Interview|Tag Count|Block Count|Average Block Size| \n"
	execute "normal! ki\<ESC>j"
	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"

	for interview_index in range(0, (len(a:interview_list) - 1))
		let l:ave_block_size = printf("%.1f", str2float(a:tag_cross[a:interview_list[interview_index]][a:tag][0]) / str2float(a:tag_cross[a:interview_list[interview_index]][a:tag][1]))
		execute "normal! i|" . a:interview_list[interview_index] . "|" . 
					\ a:tag_cross[a:interview_list[interview_index]][a:tag][0] . "|" . 
					\ a:tag_cross[a:interview_list[interview_index]][a:tag][1] . "|" .
					\ l:ave_block_size         . "|\n"
		execute "normal! ki\<ESC>j"
		let l:total_tags   = l:total_tags   + a:tag_cross[a:interview_list[interview_index]][a:tag][0]
		let l:total_blocks = l:total_blocks + a:tag_cross[a:interview_list[interview_index]][a:tag][1]
	endfor

	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"
	let l:ave_total_blocks_size = printf("%.1f", str2float(l:total_tags) / str2float(l:total_blocks))
	execute "normal! i| Totals |" . 
				\ l:total_tags             . "|" . 
				\ l:total_blocks           . "|" .
				\ l:ave_total_blocks_size  . "|\n\n"
	#execute "normal! 2ki\<ESC>2j"
	execute "normal! 2ki\<ESC>2j"
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function GraphInterviewTagSummary(tag_cross, interview, unique_tags, longest_tag_length, bar_scale) 
	let l:bar_scale_print = printf("%.1f", a:bar_scale)

	let l:report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Graph: Interview " . a:interview . "** (Updated: " . l:report_update_time . ")\n"

	for tag_index in range(0, (len(a:unique_tags) - 1))
		let l:offset       = a:longest_tag_length - len(a:unique_tags[tag_index])
		let l:block_amount = a:tag_cross[a:interview][a:unique_tags[tag_index]][1]
		let l:tag_amount   = a:tag_cross[a:interview][a:unique_tags[tag_index]][0] - l:block_amount
		if a:tag_cross[a:interview][a:unique_tags[tag_index]][0] != 0
			execute "normal! i" . a:unique_tags[tag_index] . " " . repeat(" ", l:offset) .
						\	"|" . repeat('□', str2nr(string(round(l:block_amount * a:bar_scale)))) . 
						\	repeat('▤', str2nr(string(round(l:tag_amount * a:bar_scale)))) . 
						\ 	" " . a:tag_cross[a:interview][a:unique_tags[tag_index]][0] . 
						\	"(" . a:tag_cross[a:interview][a:unique_tags[tag_index]][1] . ")\n"
		else
			execute "normal! i" . a:unique_tags[tag_index] . " " . repeat(" ", l:offset) .
						\	"|\n"
		endif
	endfor
	execute "normal! iLegend: □ = coding block bar over top of tag bar. ▤ = tag bar.\n"
	execute "normal! iScale: " . l:bar_scale_print . " square characters represent 1 observation.\n\n"
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function GraphTagInterviewSummary(tag_cross, tag, interviews, longest_tag_length, bar_scale) 
	let l:bar_scale_print = printf("%.1f", a:bar_scale)

	let l:report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Graph: Tag " . a:tag . "** (Updated: " . l:report_update_time . ")\n"

	for interview_index in range(0, (len(a:interviews) - 1))
		let l:offset       = a:longest_tag_length - len(a:interviews[interview_index])
		let l:block_amount = a:tag_cross[a:interviews[interview_index]][a:tag][1]
		let l:tag_amount   = a:tag_cross[a:interviews[interview_index]][a:tag][0] - l:block_amount
		if a:tag_cross[a:interviews[interview_index]][a:tag][0] != 0
			execute "normal! i" . a:interviews[interview_index] . " " . repeat(" ", l:offset) .
						\	"|" . repeat('□', str2nr(string(round(l:block_amount * a:bar_scale)))) . 
						\	repeat('▤', str2nr(string(round(l:tag_amount * a:bar_scale)))) . 
						\ 	" " . a:tag_cross[a:interviews[interview_index]][a:tag][0] . 
						\	"(" . a:tag_cross[a:interviews[interview_index]][a:tag][1] . ")\n"
		else
			execute "normal! i" . a:interviews[interview_index] . " " . repeat(" ", l:offset) .
						\	"|\n"
		endif
	endfor
	execute "normal! iLegend: □ = coding block bar over top of tag bar. ▤ = tag bar.\n"
	execute "normal! iScale: " . l:bar_scale_print . " square characters represent 1 observation.\n\n"
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function CreateUniqueTagList(tags_desc) 
	let l:unique_tags = []
	for index in range(0, len(a:tags_desc) - 1)
		if (index(l:unique_tags, a:tags_desc[index][2]) == -1)
			let l:unique_tags = l:unique_tags + [a:tags_desc[index][2]]
		endif
	endfor
	return l:unique_tags
endfunction 

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function FindLengthOfLongestTag(tag_list) 
	let l:longest_tag_length = 0
	for index in range(0, len(a:tag_list) - 1)
		let l:test_length = len(a:tag_list[index])
		if l:test_length > l:longest_tag_length
			let l:longest_tag_length = l:test_length
		endif
	endfor
	return l:longest_tag_length
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function TagStats() 

	call ParmCheck()
	
	let l:ext_length = (len(g:vimwiki_wikilocal_vars[g:wiki_number]['ext']) + 1) * -1

	# save buffer number of current file to register 'a' so you can return here
	let @a = bufnr('%')
	
	let g:interview_list = []
	call GetInterviewFileList()

	let g:tags_list = []
	
	# Go through each interview file building up a list of tags
	for interview in range(0, (len(g:interview_list) - 1))
		# go to interview file
		execute "normal :e " . g:interview_list[interview] . "\<CR>"
		let g:interview_to_crawl = expand('%:t:r')
		call CrawlBufferTags(interview, g:interview_to_crawl)	
	endfor

	let g:unique_tags = sort(CreateUniqueTagList(g:tags_list))

	let g:tag_cross   = CalcInterviewTagCrosstabs(g:tags_list, g:unique_tags, g:interview_list, l:ext_length)
	
	# Find the longest tag in terms of the number of characters in the tag.
	let l:len_longest_tag = FindLengthOfLongestTag(g:unique_tags)

	let l:window_width = winwidth('%')

	# Find the largest tag and block tallies. This will be used in the scale calculation for graphs.
	# Multiplying by 1.0 is done to coerce integers to floats.
	let l:largest_tag_and_block_counts = FindLargestTagAndBlockCounts(g:tag_cross, g:unique_tags, g:interview_list, l:ext_length)
	let l:largest_tag_count           = l:largest_tag_and_block_counts[0] * 1.0
	let l:largest_block_count         = l:largest_tag_and_block_counts[1] * 1.0

	# find the number of digits in the following counts. Used for
	# calculating the graph scale. The nested functions are mostly to
	# convert the float to an lint. Vimscript doesn't have a direct way to do this.
	let l:largest_tag_count_digits    = str2nr(string(trunc(log10(l:largest_tag_count) + 1)))
	let l:largest_block_count_digits  = str2nr(string(trunc(log10(l:largest_block_count) + 1)))

	let l:max_bar_width = l:window_width - l:len_longest_tag - l:largest_tag_count - l:largest_tag_count_digits - l:largest_block_count_digits - 8
	let l:bar_scale     = l:max_bar_width / l:largest_tag_count

	# Return to the buffer where these charts and graphs are going to be
	# produced and clear out the buffer.
	execute "normal! :b\<C-R>a\<CR>gg"
	execute "normal! ggVGd"

	# Print interview tag summary tables
	for interview in range(0, (len(g:interview_list) - 1))
		call PrintInterviewTagSummary(g:tag_cross, g:interview_list[interview], g:unique_tags)	
	endfor
	#Print tag interview summary tables
	for tag_index in range(0, (len(g:unique_tags) - 1))
		call PrintTagInterviewSummary(g:tag_cross, g:unique_tags[tag_index], g:interview_list)
	endfor
	# Print interview tag summary graphs
	for interview in range(0, (len(g:interview_list) - 1))
		call GraphInterviewTagSummary(g:tag_cross, g:interview_list[interview], g:unique_tags, l:len_longest_tag, l:bar_scale)	
	endfor
	# Print interview tag summary graphs
	for tag_index in range(0, (len(g:unique_tags) - 1))
		call GraphTagInterviewSummary(g:tag_cross, g:unique_tags[tag_index], g:interview_list, l:len_longest_tag, l:bar_scale)	
	endfor
	
	#execute "normal! iLongest tag " . l:len_longest_tag . "\n"
	#execute "normal! iMax bar width " . l:max_bar_width . "\n"
	#execute "normal! ilargest_tag_count " . l:largest_tag_count . "\n"
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function PopulateQuoteLineList() 
	let g:current_line_dict   = {}
	let g:current_line_dict = { "int_name"    : g:current_buf_name,
				\   "bufnr"       : g:ll_bufnr,
				\   "text_w_meta" : g:line_text,
				\   "text"        : g:line_text_less_meta,
				\   "line_num"    : g:current_int_line_num}
	
	if len(g:quote_dict) == 0

		let g:quote_dict[g:current_buf_name] = [[ g:current_line_dict ]]
	elseif (g:current_buf_name == g:last_int_name)
		if g:current_int_line_num - g:last_int_line_num == 1 
			let g:quote_dict[g:current_buf_name][g:block_count] = g:quote_dict[g:current_buf_name][g:block_count] + [ g:current_line_dict ]
		else
			let g:quote_dict[g:current_buf_name]                = g:quote_dict[g:current_buf_name] + [[ g:current_line_dict ]]
			let g:block_count = g:block_count + 1 
		endif
	elseif (g:current_buf_name != g:last_int_name)
		let g:block_count = 0
		let g:quote_dict[g:current_buf_name] = [[ g:current_line_dict ]]
	endif
endfunction

function BuildListOfCrossCodes(text_w_meta) 
	let l:tag_test = matchstrpos(a:text_w_meta, ':\a.\{-}:', 0)
	while (l:tag_test[1] != -1)
		if (index(g:cross_codes, l:tag_test[0]) == -1)
			let g:cross_codes = g:cross_codes + [ l:tag_test[0] ]
		endif
		let l:tag_test = matchstrpos(a:text_w_meta, ':\a.\{-}:', l:tag_test[2])
	endwhile
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function ProcessInterviewLines(meta, report_type, search_term) 
	if has_key(g:quote_dict, g:interview_list[g:int_index])
		if a:report_type != "VWS"
			let @s = @s . "**TAGGED LINES:**\n\n"
		else
			let @s = @s . "**MATCHED LINES:**\n\n"
		endif
		if a:meta == "meta"
			let l:line_type = "text_w_meta"
		else
			let l:line_type = "text"
		endif
		let l:blocks = len(g:quote_dict[g:interview_list[g:int_index]])
		for l:block_index in range(0, l:blocks - 1)
			let g:csv_block = ""
			let l:first_line_num = printf("%04d", g:quote_dict[g:interview_list[g:int_index]][l:block_index][0]["line_num"])
			let l:last_line_num  = printf("%04d", g:quote_dict[g:interview_list[g:int_index]][l:block_index][-1]["line_num"])
			let l:lines = len(g:quote_dict[g:interview_list[g:int_index]][l:block_index])
			let g:block = ""
			let g:cross_codes = []
			for l:line_index in range(0, l:lines - 1)
				if (a:meta == "meta")
					let g:block = g:block . g:quote_dict[g:interview_list[g:int_index]][l:block_index][l:line_index]["text_w_meta"] . "\n"
				else
					let g:block = g:block . g:quote_dict[g:interview_list[g:int_index]][l:block_index][l:line_index]["text"]
					call BuildListOfCrossCodes(g:quote_dict[g:interview_list[g:int_index]][l:block_index][l:line_index]["text_w_meta"])
				endif
				let l:csv_line = CreateCSVRecord(a:search_term, l:block_index, l:line_index)
				let g:csv_block = g:csv_block . l:csv_line . "\n"
			endfor
			if (a:meta != "meta")
				let g:block = substitute(g:block, '\s\+', ' ', "g")
				let g:block = substitute(g:block, '(\d:\d\d:\d\d)\sspk_\d:\s', '', "g") 
				let g:cross_codes_string = string(g:cross_codes)
				let g:cross_codes_string = substitute(g:cross_codes_string, "\'", ' ', "g")
				let g:cross_codes_string = substitute(g:cross_codes_string, ',', '', "g")
				let g:cross_codes_string = substitute(g:cross_codes_string, '\s\+', ' ', "g")

				let g:block = g:block . " **" . g:interview_list[g:int_index] . ": " . l:first_line_num . " - " . l:last_line_num . "** " . g:cross_codes_string . "\n\n"
			endif

			let @s = @s . g:block
			let @u = @u . g:csv_block

			if (a:meta == "meta")
				let @s = @s . "\n"
			endif
		endfor
	endif
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function ProcessInterviewTitle(interview) 
	let g:attribute_line = GetAttributeLine(a:interview)

	let g:interview_title = "\n# ======================================\n# INTERVIEW: "
				\	. a:interview .
				\	#\n# ======================================\n**ATTRIBUTES:** "
				\	. g:attribute_line . "\n"

	let @s = @s . g:interview_title
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function GetInterviewLineInfo(line_text) 
	let l:interview_label_position      = match(a:line_text, g:tag_search_regex)
	let l:interview_line_num_pos        = match(a:line_text, ' \d\{4}', l:interview_label_position)
	let l:current_interview_line_number = str2nr(a:line_text[(l:interview_line_num_pos + 1):(l:interview_line_num_pos + 4)])
	return l:current_interview_line_number
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function CreateSummaryCountTableLine() 
	
	let l:number_of_blocks = 0
	let l:number_of_lines  = 0
	if has_key(g:quote_dict, g:unique_keys[g:int_index])
		let l:number_of_blocks = len(g:quote_dict[g:unique_keys[g:int_index]])
		for l:block_index in range(0, l:number_of_blocks - 1)
			let l:number_of_lines = l:number_of_lines + len(g:quote_dict[g:unique_keys[g:int_index]][l:block_index])
		endfor
	endif 

	let l:lines_per_block = str2float(l:number_of_lines) / str2float(l:number_of_blocks)
	let l:lines_per_block = printf("%.1f", l:lines_per_block)

	let l:number_of_annos = 0
	if has_key(g:anno_dict, g:unique_keys[g:int_index])
		let l:number_of_annos = len(g:anno_dict[g:unique_keys[g:int_index]])
	endif 

	let g:total_blocks = g:total_blocks + l:number_of_blocks
	let g:total_lines  = g:total_lines  + l:number_of_lines
	let g:total_annos  = g:total_annos  + l:number_of_annos

	let l:interview_number = g:int_index + 1
	let @t = @t . 
				\ "| " . l:interview_number .
				\ "| [" . g:unique_keys[g:int_index] . "](" .
				\ g:unique_keys[g:int_index] . ") | " . 
				\ l:number_of_blocks .  " | " .
				\ l:number_of_lines . " | " . 
				\ l:lines_per_block . " | " . 
				\l:number_of_annos . " |\n"

endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function ProcessAnnotationLines() 
	if has_key(g:anno_dict, g:interview_list[g:int_index])
		let l:annos = len(g:anno_dict[g:interview_list[g:int_index]])
		let g:int_annos = ""
		for l:anno_index in range(0, l:annos - 1)
			let l:anno_num = l:anno_index + 1
			let g:int_annos = g:int_annos . 
						\ "**ANNOTATION " . 
						\ l:anno_num  .
						\ ":**\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n" .
						\ g:anno_dict[g:interview_list[g:int_index]][l:anno_index]["text"] .
						\ ">>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n"
		endfor
		let @s = @s . g:int_annos
	endif
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function PopulateAnnoLineList(buf_type) 
	let g:current_anno_dict           = {}
	let g:current_anno_int_name       = GetAnnoInterview(g:current_buf_name)
	let g:anno_text                   = GetAnnoText(g:ll_bufnr)
	let g:current_anno_dict = { "int_name"    : g:current_anno_int_name,
				\   "anno_name"   : g:current_buf_name,
				\   "bufnr"       : g:ll_bufnr,
				\   "text"        : g:anno_text }
	
	if len(g:anno_dict) == 0
		let g:anno_dict[g:current_anno_dict.int_name] = [ g:current_anno_dict ]
	elseif (g:current_anno_dict.int_name == g:last_anno_int_name)
		if (g:current_buf_name != g:last_anno_buf_name)
			let g:anno_dict[g:current_anno_dict.int_name] = g:anno_dict[g:current_anno_dict.int_name] + [ g:current_anno_dict ]
		endif
	elseif (g:current_anno_dict.int_name != g:last_anno_int_name)
		let g:anno_dict[g:current_anno_dict.int_name] = [ g:current_anno_dict ]
	endif
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function GetAnnoInterview(buffer_name) 
	let l:line_num_loc  = match(a:buffer_name, ':')
	let l:cropped_name  = a:buffer_name[0:l:line_num_loc - 1]
	return l:cropped_name
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function GetAnnoText(bufnr) 
	# Go to the Location List result under the cursor.
	execute "normal! :buffer " . a:bufnr . "\<CR>"
	# Copy the annotation text.
	execute "normal! G$?.\<CR>Vggy"
	return @@
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function CreateCSVRecord(search_term, block_index, line_index) 
	# -----------------------------------------------------------------
	# Build output record
	# -----------------------------------------------------------------
	let l:attributes = substitute(g:attribute_line, '\s\+', '', "g")
	let l:attributes = substitute(l:attributes , ":", ",", "g")
	let l:attributes = l:attributes[:-3]
	let l:block = a:block_index + 1
	let l:outline =           a:search_term . "," .
				\ g:interview_list[g:int_index] . "," .
				\ l:block . "," .
				\ g:quote_dict[g:interview_list[g:int_index]][a:block_index][a:line_index]["line_num"] . "," .
				\ "\"" . g:quote_dict[g:interview_list[g:int_index]][a:block_index][a:line_index]["text"] . "\"," .
				\ g:current_buf_length . 
				\ l:attributes 

	return l:outline
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function FindBufferType(current_buf_name) 
	if match(a:current_buf_name, "Summary") != -1
		return "Summary"
	elseif match(a:current_buf_name, ': \d\{4}') != -1
		return  "Annotation"
	elseif match(a:current_buf_name, g:interview_label_regex) != -1
		return "Interview"
	else
		return "Other"
	endif
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function RemoveMetadata(line_text) 
	# -----------------------------------------------------------------
	#  There is something strange going on here. You shouldn't
	#  have to go back 6 columns from the match. If you don't you
	#  get <e2><94> characters at the end of the line. I can't
	#  figure out what these are but if you chop them off the
	#  function works.
	# -----------------------------------------------------------------
	let g:border_location = match(a:line_text, g:tag_search_regex) - 6
	return a:line_text[:g:border_location]
endfunction



# ------------------------------------------------------
#
# ------------------------------------------------------
function AddReportHeader(report_type, search_term) 
	let l:report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	let l:report_header = "\n# *********************************************************************************\n"
	let l:report_header = l:report_header . "# *********************************************************************************\n"
	let l:report_header = l:report_header . "  **" . a:report_type . "(\"" . a:search_term . "\")**\n  Created by **" . g:coder_initials . "**\n  on **" . l:report_update_time . "**"
	let l:report_header = l:report_header . "\n# *********************************************************************************"
	let l:report_header = l:report_header . "\n# *********************************************************************************"
	let @q = l:report_header . "\n\n**SUMMARY TABLE:**\n\n" 
endfunction


# ------------------------------------------------------
#
# ------------------------------------------------------
function GetAttributeLine(interview) 
	# -----------------------------------------------------------------
	# Go to the Location List result under the cursor.
	# -----------------------------------------------------------------
	execute "normal! :e " . a:interview . "\.md\<CR>"
	# -----------------------------------------------------------------
	# Get the first line and the length of the buffer in lines.
	# -----------------------------------------------------------------
	execute "normal! ggVy"
	let g:attribute_row = @@
	let g:current_buf_length = line('$')
	execute "normal! \<C-o>"
	return g:attribute_row
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function TrimLeadingPartialSentence() 
	#execute "normal! vip\"by"
	#execute "normal! `<v)hx"
	execute "normal! 0v)hx"
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function TrimTrailingPartialSentence() 
	execute "normal! $"
	let g:trim_tail_regex = '**' . g:tag_search_regex
	let g:tag_test = search(g:trim_tail_regex, 'b', line("."))
	execute "normal! hv(d0"
	#execute "normal! $" . '?**' . g:tag_search_regex . "\<CR>hv(d"
	#execute "normal! vip\"by"
	#execute "normal! `>(v)di\r\r\<ESC>kk"
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function TrimLeadingAndTrailingPartialSentence() 
	call TrimLeadingPartialSentence()
	call TrimTrailingPartialSentence()
endfunction


# -----------------------------------------------------------------
# ------------------------------- TAGS  ---------------------------
# -----------------------------------------------------------------

# ------------------------------------------------------
#
# ------------------------------------------------------
augroup Has_VWQC_Config_Been_Loaded
	autocmd!
	autocmd BufEnter index.* :call TagsLoadedCheck()
augroup END

# ------------------------------------------------------
#
# ------------------------------------------------------
def TagsLoadedCheck()
	var last_wiki_warning = ""
	if has_key(g:vimwiki_list[vimwiki#vars#get_bufferlocal('wiki_nr')], 'vwqc')
		if (!exists("g:last_wiki"))
			ParmCheck()
			last_wiki_warning = "No VWQC wiki tags have been populated this session. " ..
				"Press <F2> to update tags."
			confirm(last_wiki_warning, "OK", 1)
		elseif (g:last_wiki != vimwiki#vars#get_bufferlocal('wiki_nr'))
			ParmCheck()
			last_wiki_warning = "The currently-loaded VWQC tags are for another project. " ..
				"Press <F2> to load tags for this project."
			confirm(last_wiki_warning, "OK", 1)
		endif
	endif	
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
function GetTagUpdate() 

	ParmCheck()

	call confirm("Populating tags. This may take a while.", "Got it", 1)
	call CreateTagDict()

	execute "normal! :delmarks Y\<CR>"
	execute "normal! mY"
	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# ------------------------------------------------------
	# Find the vimwiki that the current buffer is in.
	# ------------------------------------------------------
	let g:wiki_number = vimwiki#vars#get_bufferlocal('wiki_nr') 
	# -----------------------------------------------------------------
	# Save the current buffer so any new tags are found by
	# VimwikiRebuildTags
	# -----------------------------------------------------------------
	execute "normal :w\<CR>"
	call GenTagsWithLocationList()
	# -----------------------------------------------------------------
	# g:current_tags is used in vimwiki's omnicomplete function. At this
	# point this is a modifcation to ftplugin#vimwikimwiki#Complete_wikifiles
	# where
	#    let tags = vimwiki#tags#get_tags()
	# has been replaced by
	#    let tags = deepcopy(g:current_tags)
	# This was done because as the number of tags grows in a project
	# vimwiki#tags#get_tags() slows down.
	# -----------------------------------------------------------------
	let g:current_tags = sort(g:current_tags, 'i')
	# ------------------------------------------------------
	# Set the current wiki as the wiki that g:current_tags were last
	# generated for. Also mark that a set of current tags has been
	# generated to true.
	# ------------------------------------------------------
	let g:last_wiki_tags_generated_for = g:wiki_number
	let g:current_tags_set_this_session = 1
	# ------------------------------------------------------
	# Popup menu to display the list of current tags sorted in
	# case-insenstive alphabetical order
	# ------------------------------------------------------
	call GenDictTagList()
	call UpdateCurrentTagsList()
	call UpdateCurrentTagsPage()
	call CurrentTagsPopUpMenu()

	let g:current_tags = sort(g:just_in_dict_list + g:just_in_current_tag_list + g:in_both_lists)

	# ------------------------------------------------------
	# Add an element to the current wiki's configuration dictionary that
	# marks it as having had its tags generated in this vim session.
	# ------------------------------------------------------
	let g:vimwiki_wikilocal_vars[g:wiki_number]['tags_generated_this_session'] = 1
	execute "normal! `Yzz"
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
def GenTagsWithLocationList() 
	ParmCheck()
	# Change the pwd to that of the current wiki.
	execute "normal! :cd %:p:h\<CR>"
	# Call VimwikiSearchTags against the a:search_term argument.
	# Put the result in loc_list which is a list of location list
	# dictionaries that we'll process.
	silent execute "normal! :VimwikiSearch /" . '\(^\|\s\)\zs:\([^:''[:space:]]\+:\)\+\ze\(\s\|$\)' . "/g\<CR>"

	var g:loc_list = getloclist(0)
	var g:tag_list = []

	var g:num_search_results = len(g:loc_list)

	var first_col = g:loc_list[0]['col'] 
	var last_col  = g:loc_list[0]['end_col'] - 3
	var g:test_tag  = g:loc_list[0]['text'][first_col:last_col]

	if g:loc_list[0]['lnum'] > 1
		g:tag_list = g:tag_list + [ g:test_tag ]
	endif

	for g:line_index in range(1, g:num_search_results - 1)
		first_col = g:loc_list[g:line_index]['col'] 
		last_col  = g:loc_list[g:line_index]['end_col'] - 3
		g:test_tag = g:loc_list[g:line_index]['text'][first_col:last_col]
		if (index(g:tag_list, g:test_tag) == -1)
			let g:tag_list = g:tag_list + [ g:test_tag ]
		endif
	endfor	
	var g:current_tags = deepcopy(g:tag_list)
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
function UpdateCurrentTagsPage() 
	# -----------------------------------------------------------------
	# Use R mark to know how to get back
	# -----------------------------------------------------------------
	execute "normal! :delmarks R\<CR>"
	execute "normal! mR"
	# Open the Tag List Current Page
	execute "normal! :e " . g:vimwiki_wikilocal_vars[g:wiki_number]['path'] . "Tag List Current" . g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] . "\<CR>"
	# Delete what is there
	execute "normal! ggVGd"
	let l:tag_update_time = strftime("%Y-%m-%d %a %H:%M:%S")
	execute "normal! i**Tag list last updated at: " . l:tag_update_time . "**\n\<CR>"
	execute "normal! i- **There are " . len(g:in_both_lists) . " tag(s) defined in the Tag Glossary and included in the current tags list.**\n"
	put =g:in_both_lists
	execute "normal! Go"
	execute "normal! i\n- **There are " . len(g:just_in_current_tag_list) . " tag(s) included in the current tags list, but not defined in the Tag Glossary.**\n"
	put =g:just_in_current_tag_list
	execute "normal! Go"
	execute "normal! i\n- **There are " . len(g:just_in_dict_list) . " tag(s) defined in the Tag Glossary but not used in coding.**\n"
	put =g:just_in_dict_list
	execute "normal! ggj"
	# Return to where you were
	execute "normal! `Rzz"
	
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function UpdateCurrentTagsList() 
	let g:tag_dict_keys 		= keys(g:tag_dict)
	let g:tag_dict_keys 		= sort(g:tag_dict_keys, 'i')
	
	let g:tag_list_output           = []
	let g:in_both_lists  		= []
	let g:just_in_dict_list		= []
	let g:just_in_current_tag_list	= []

	for l:tag_dict_tag in range(0, (len(g:tag_dict_keys) - 1))
		let l:is_in_list = index(g:current_tags, g:tag_dict_keys[l:tag_dict_tag])
		if l:is_in_list >= 0
			let l:print_list_item = g:tag_dict_keys[l:tag_dict_tag]
			let g:in_both_lists = g:in_both_lists + [l:print_list_item]
		elseif l:is_in_list < 0
			let l:print_list_item = g:tag_dict_keys[l:tag_dict_tag]
			let g:just_in_dict_list = g:just_in_dict_list + [l:print_list_item]
		endif
	endfor

	for l:current_tag in range(0, (len(g:current_tags) - 1))
		let l:is_in_list = index(g:tag_dict_keys, g:current_tags[l:current_tag])
		if l:is_in_list < 0
			let l:print_list_item = g:current_tags[l:current_tag]
			let g:just_in_current_tag_list = g:just_in_current_tag_list + [l:print_list_item]
		endif
	endfor

	let g:tag_list_output = ["DEFINED:", " "] + g:in_both_lists + [" ", "UNDEFINED:", " "] + g:just_in_current_tag_list + [" ", "DEFINED BUT NOT USED:", " "] + g:just_in_dict_list 
	#let g:tag_list_output = sort(g:tag_list_output)


endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
def TagsGenThisSession() 
	
	ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# ------------------------------------------------------
	# See if the wiki config dictionary has had a
	# tags_generated_this_session key added.
	# ------------------------------------------------------
	var g:tags_gen_this_wiki_this_session = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	# ------------------------------------------------------
	# Checks to see if we have the proper current tag list for our tag
	# omnicompletion.
	# ------------------------------------------------------
	if !exists("g:current_tags_set_this_session")
		NoTagListNotice(1)
	else
		if g:tags_gen_this_wiki_this_session != 1 
			NoTagListNotice(2)
		else
			if g:last_wiki_tags_generated_for != g:wiki_number
				NoTagListNotice(3)
			else
				# ------------------------------------------------------
				# The ! after startinsert makes it insert after (like A). If
				# you don't have the ! it inserts before (like i)
				# ------------------------------------------------------
				startinsert!
				feedkeys("\<c-x>\<c-o>")
			endif
		endif
	endif
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
function ToggleDoubleColonOmniComplete() 
	if maparg("::", "i") == ""
		inoremap :: <ESC>a:<ESC>:call TagsGenThisSession()<CR>
		call confirm("Double colon (::) omni-completion on.", "Got it", 1)
	else
		iunmap ::
		call confirm("Double colon (::) omni-completion off.", "Got it", 1)
	endif
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
def GenDictTagList() 
	var g:dict_tags = []
	for tag_index in range(0, (len(g:current_tags) - 1))
 		if has_key(g:tag_dict, g:current_tags[tag_index])
			g:dict_tags = g:dict_tags + [g:current_tags[tag_index]]
		endif
	endfor
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def CreateTagDict() 
	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Use Y mark to know how to get back
	# -----------------------------------------------------------------
	execute "normal! mY"
	# -----------------------------------------------------------------
	# Go to the tag glossary
	# -----------------------------------------------------------------
	execute "normal! :e Tag Glossary" . g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] . "\<CR>"
	execute "normal! gg"
	# -----------------------------------------------------------------
	# Define an empty tag dictionary
	# -----------------------------------------------------------------
	var g:tag_dict = {}
	# -----------------------------------------------------------------
	# Build the tag dictionary. 
	# -----------------------------------------------------------------
	while search('{', "W")
		execute "normal! j$bviWy0"
		var tag_key = @@
		var tag_def_list = []
		while (getline(".") != "}") && (line(".") <= line("$"))
			tag_def_list = tag_def_list + [getline(".")]
			execute "normal! j0"
		endwhile
		#execute "normal! jvi\{y"
		g:tag_dict[tag_key] = tag_def_list
	endwhile
	# -----------------------------------------------------------------
	# Return to the buffer you called this function from
	# -----------------------------------------------------------------
	execute "normal! `Y"
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def CurrentTagsPopUpMenu() 
	popup_menu(g:tag_list_output , 
				 { minwidth: 50,
				 maxwidth: 50,
				 pos: 'center',
				 border: [],
				 close: 'click',
				 })
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def NoTagListNotice(tag_message: number) 
	if (tag_message == 1)
		var popup_message = "Press <F2> to populate the current tag list."
	elseif (a:tag_message == 2)
		var popup_message = "A tag list for this wiki has not been generated yet this session. Press <F2> to populate the current tag list with this wiki\'s tags."
	else 
		var popup_message = "Update the tag list with this wiki\'s tags by pressing <F2>."
	endif
	confirm(popup_message, "Got it", 1)
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
function TagFillWithChoiceOLD() 
	# ---------------------------------------------
	# Create an empty matched-tag-list
	# ---------------------------------------------
	let g:matched_tag_list = []
	# ---------------------------------------------
	# Set tag fill mode
	# ---------------------------------------------
	if !exists("g:tag_fill_option") 
		let g:tag_fill_option = "last tag added"
	endif
	if (g:tag_fill_option == "last tag added")
		call FindLastTagAddedToBuffer()
	endif
	# ----------------------------------------------------
	# Mark the line and column number where you want the bottom of the tag block to be.
	# -----------------------------------------------------
	let g:bottom_line = line('.')
	let g:bottom_col = virtcol('.')
	# -----------------------------------------------------
	# Find tags in lines above and add them to a list until the there is a gap between the lines with tags
	# Search for first match the bW means search backwards and don't wrap around the end of the file.
	# -----------------------------------------------------
	let g:match_line = search(':\a.\{-}:', 'bW')
	# -----------------------------------------------------
	#  As long as we find a match (ie the result of the search function is not equal to zero) that is not the attribute line (1) continue.
	#  ----------------------------------------------------
	if (g:match_line <= 1)
		call cursor(g:bottom_line, g:bottom_col)
		call confirm("No tags found above the cursor",  "OK", 1)
	else
		# ----------------------------------------------
		# Set the last-matched-line equal to the matched-line. This is the first case situation.
		# ----------------------------------------------
		let g:last_match_line = g:match_line
		# ----------------------------------------------
		# Copy the first found tag and add it to the matched-tag-list. Note the hh at the end of the execute statement moves the
		# cursor to the left of the tag we just matched. This is so it doesn't get selected again when we look for more tags.
		# ----------------------------------------------
		execute "normal! lviWylvt:yhh"
		let g:first_tag_in_block = [@@]
		if (g:tag_fill_option == "last tag added") 
			if (len(g:matched_tag_list) == 0)
				let g:matched_tag_list = g:first_tag_in_block
			elseif (g:first_tag_in_block[0] != g:matched_tag_list[0])
				let g:matched_tag_list = g:matched_tag_list + g:first_tag_in_block
			endif
		elseif (g:tag_fill_option == "bottom of contiguous block")
			let g:matched_tag_list = g:first_tag_in_block
		endif
		# -----------------------------------------------------------
		# Set an is-contiguous-tag-block boolean to true (1).
		# -----------------------------------------------------------
		let g:is_contiguous_tagged_block = 1
		# ----------------------------------------------------------
		# Now we're going to look for the rest of the tags in a
		# contiguously tagged block above where the cursor is.
		# ----------------------------------------------------------
		while (g:is_contiguous_tagged_block == 1)
			# --------------------------------------------------
			# Search backwards ('b') for another tag.
			# --------------------------------------------------
			let g:match_line = search(':\a.\{-}:', 'bW')
			# --------------------------------------------------
			# If we found a tag (ie. The search function doesn't return a zero) decide if we need to add it to our list.
			# --------------------------------------------------
			if (g:match_line > 1)
				# -------------------------------------------
				# Copy the tag we found. 
				# -------------------------------------------
				execute "normal! lviWylvt:yhh"
				let g:this_tag = @@
				# -------------------------------------------
				# We're setting up the have-tag variable as a boolean. So have-tag is set to 0 or false.
				# -------------------------------------------
				let g:have_tag = 0
				# -------------------------------------------
				# Test to see if we already have this tag in our list. If we don't then add it to our tag
				# list. This next if-block will only run if the most recently found tag is no more than
				# one line above the previously found tag. i.e. That the tags are part of a contiguous block
				# -------------------------------------------
				if (g:last_match_line - g:match_line <= 1)
					# -----------------------------------
					#  Search through the matched-tag-list to see if we already have the tag
					#  we're considering on this iteration of the while loop
					#  ----------------------------------
					for l:tag in g:matched_tag_list
						if (l:tag == g:this_tag)
							let g:have_tag = 1
						endif
					endfor
					# -----------------------------------
					# If have tag is still false then we'll add it to our match-tag-list.
					# Note we're not sorting our list.This means that the tags will be in
					# the order they are found as we search backwards.
					# -----------------------------------
					if (g:have_tag == 0)
						let g:matched_tag_list = g:matched_tag_list + [g:this_tag]
					endif
					# -----------------------------------
					# Before we iterate again we have to make the last-match-line equal to
					# our current match-line.
					# ----------------------------------
					let g:last_match_line = g:match_line
				else
					# -----------------------------------
					# If the most recently found tag is on a line more than one line above the
					# previously found tag then we found a tag outside of the tag block.
					# -----------------------------------
					let g:is_contiguous_tagged_block = 0
				endif
			else
				let g:is_contiguous_tagged_block = 0
			endif 

		endwhile	
		# ------------------------------------------------------------
		# The choice number is the matched tag list index number. So 0 is the first element in the list. This will be the first tag
		# we found when we searched backwards. 
		# ------------------------------------------------------------
		call cursor(g:bottom_line, g:bottom_col)
		let g:choice = 0
		# ------------------------------------------------------------
		#  If the list has more than one element you want the user to choose the proper tag. Hitting enter chooses the first item in the list.
		# ------------------------------------------------------------
		if (len(g:matched_tag_list) > 1)
			call popup_menu(g:matched_tag_list, #{
				\ title:    "Choose tag (Mode = " . g:tag_fill_option . "; F4 to change mode)"   ,
				\ callback: 'FillChosenTag'  , 
				\ highlight: 'Question'       ,
				\ border:     []              ,
				\ close:      'click'         , 
				\ padding:    [0,1,0,1],
				\ })
		elseif (len(g:matched_tag_list) == 1)
			let g:tag_to_fill = ":" . g:matched_tag_list[0] . ":"
			# ------------------------------------------------------------
			# Now we have to find the range to fill
			# ------------------------------------------------------------
			call cursor(g:bottom_line, g:bottom_col)
			let g:line_of_tag_to_fill = search(g:tag_to_fill, 'bW')
			if (g:line_of_tag_to_fill != 0)
				let g:lines_to_fill = g:bottom_line - g:line_of_tag_to_fill
				call cursor(g:bottom_line, g:bottom_col)
				execute "normal! V" . g:lines_to_fill . "k\<CR>:s/$/ " . g:tag_to_fill . "/\<CR>A \<ESC>"
			else
				call confirm("Tag not found above the cursor",  "OK", 1)
			endif
		endif

		
	endif	
endfunction

# ------------------------------------------------------------
# Find the last tag entered on the page. Do this by putting
# :changes into register c and then searching it for the
# first tag. 
# ------------------------------------------------------------
function FindLastTagAddedToBuffer() 
	# ------------------------------------------------------------
	#  Redirect output to register changes variable
	# ------------------------------------------------------------
	set nomore
	redir => g:changes
	changes
	redir END
	set more
	# ------------------------------------------------------------
	# Redraw to get past the "press Enter" message that the
	# changes command produces
	# ------------------------------------------------------------
	redraw!
	# ------------------------------------------------------------
	# Find the last tag in changes variable. Note the regex here
	# finds a tag that isn't followed by a tag. This is
	# called a negative lookahead. First you need to take out the
	# line breaks in what is sent to the changes variable register.
	# ------------------------------------------------------------
	let g:changes = substitute(g:changes, '\n', '', "g")

	let g:most_recent_tag_in_changes       = ""
	let g:is_tag_on_page                   = 0
	let g:most_recent_tag_in_changes_start = match(g:changes, ':\a\w\{1,}:\(.*:\a\w\{1,}:\)\@!')
	# ------------------------------------------------------------
	# If there is a tag on the page, find what it is.
	# ------------------------------------------------------------
	if g:most_recent_tag_in_changes_start != -1
		let g:most_recent_tag_in_changes_end = match(g:changes, ':', g:most_recent_tag_in_changes_start + 1)
		let g:most_recent_tag_in_changes = g:changes[(g:most_recent_tag_in_changes_start + 1):(g:most_recent_tag_in_changes_end - 1)]
		let g:is_tag_on_page = 1
	endif
	# ------------------------------------------------------------
	# Next we have to take g:most_recent_tag_in_changes and make it the
	# first tag in matched_tag_list. We'll also have to make sure
	# that it doesn't appear in matched tag list twice.
	# ------------------------------------------------------------
	if g:is_tag_on_page == 1
		let g:matched_tag_list = [g:most_recent_tag_in_changes] 
	endif
endfunction

function FillChosenTag(id, result) 
	# ------------------------------------------------------------
	# When ESC is press the a:result value will be -1. So take no action.
	# ------------------------------------------------------------
	if (a:result > 0)
		# ------------------------------------------------------------
		# Now we have our choice which corresponds to the matched-tag-
		# list element. All that remains is to fill the tag.
		# ------------------------------------------------------------
		let g:tag_to_fill = ":" . g:matched_tag_list[a:result - 1] . ":"
		# ------------------------------------------------------------
		# Now we have to find the range to fill
		# ------------------------------------------------------------
		call cursor(g:bottom_line, g:bottom_col)
		let g:line_of_tag_to_fill = search(g:tag_to_fill, 'bW')
		# ------------------------------------------------------------
		# If the tag_to_fill is found above the cursor position, and
		# its not more than 20 lines above the contiguously tagged
		# block above the cursor position.
		# ------------------------------------------------------------
		let g:proceed_to_fill = 0
		if (g:tag_fill_option == "bottom of contiguous block")
			let g:lines_to_fill = g:bottom_line - g:line_of_tag_to_fill
			let g:proceed_to_fill = 1
		elseif (g:line_of_tag_to_fill != 0)
			#execute "normal! ?" . g:tag_to_fill . "\<CR>"
			let g:lines_to_fill = g:bottom_line - g:line_of_tag_to_fill
			let g:proceed_to_fill = 1
		endif
		# ------------------------------------------------------------
		# This actually fills the tag.
		# ------------------------------------------------------------
		call cursor(g:bottom_line, g:bottom_col)
		if (g:proceed_to_fill)
			execute "normal! V" . g:lines_to_fill . "k\<CR>:s/$/ " . g:tag_to_fill . "/\<CR>A \<ESC>"
		else
			call confirm("Tag not found above the cursor. No action taken.",  "OK", 1)
		endif
	endif
endfunction
	
function TagFillWithChoice() 
	# ---------------------------------------------
	# Set tag fill mode
	# ---------------------------------------------
	if !exists("g:tag_fill_option") 
		let g:tag_fill_option = "last tag added"
	endif
	if (g:tag_fill_option == "last tag added")
		call FindLastTagAddedToBuffer()
	endif
	# ----------------------------------------------------
	# Mark the line and column number where you want the bottom of the tag block to be.
	# -----------------------------------------------------
	let g:bottom_line = line('.')
	let g:bottom_col = virtcol('.')
	
	let g:block_tags_list = []
	let g:tag_block_dict  = {}

	call CreateBlockMetadataDict()

	call cursor(g:bottom_line, g:bottom_col)
	# ------------------------------------------------------------
	#  If the list has more than one element you want the user to 
	#  choose the proper tag. Hitting enter chooses the first item in the list.
	# ------------------------------------------------------------
	if (len(g:block_tags_list) >= 1)
		call popup_menu(g:block_tags_list, #{
			\ title:    "Choose tag (Mode = " . g:tag_fill_option . "; F4 to change mode)"   ,
			\ callback: 'BuildMetadataBlockFill'  , 
			\ highlight: 'Question'       ,
			\ border:     []              ,
			\ close:      'click'         , 
			\ padding:    [0,1,0,1],
			\ })
	else	
		call confirm("Tag not found above the cursor",  "OK", 1)
	endif

	call cursor(g:bottom_line, g:bottom_col)
	execute "normal! zzA "
endfunction

function FillTagBlock(id, result) 
	# ------------------------------------------------------------
	# When ESC is press the a:result value will be -1. So take no action.
	# ------------------------------------------------------------
	if (a:result > 0)

		let g:block_range_as_char = keys(g:tag_block_dict)
		let g:block_range         = []

		for l:index in range(0, len(g:block_range_as_char) - 1)
			let g:block_range = g:block_range + [ str2nr(g:block_range_as_char[l:index]) ]
		endfor

		let g:block_range     = sort(g:block_range)
		
		let g:block_range_max = g:bottom_line
		let g:block_range_min = min(g:block_range)

		for l:index_2 in range(g:block_range_min, g:block_range_max)
			if has_key(g:tag_block_dict, l:index_2)
				if (index(g:tag_block_dict[l:index_2][0], g:tag_list_to_present[a:result - 1]) != -1)
					let g:top_fill_line = l:index_2
				endif
			endif
		endfor

		for l:index_3 in range(g:block_range_min, g:block_range_max)
			call CreateFillLine(l:index_3)
			call cursor(l:index_3, g:tag_block_dict[l:index_3][2])
			execute "normal! i" . g:meta_fill_line . "\<CR>"
		endfor
	endif
endfunction

function CreateFillLine(line) 
	let g:meta_fill_line = ""
	for l:tags in range(0, len(g:block_tags_list) - 1)
		if has_key(g:tag_block_dict, a:line)
			# if this line has the block
			if (index(g:tag_block_dict[a:line][0], g:block_tags_list[l:tags] != -1))
				let g:meta_fill_line = g:meta_fill_line . " :" . g:block_tags_list[l:tags] . ":"
			elseif (a:line >= g:top_fill_line)
				let g:meta_fill_line = g:meta_fill_line . " :" . g:block_tags_list[l:tags] . ":"
			else
				let l:spacer = repeat(" ", len(g:block_tags_list[l:tags])) + 3 
				let g:meta_fill_line = g:meta_fill_line . l:spacer
			endif
		endif			
	endfor
	if (has_key(g:block_tag_list) == -1) and (a:line >= g:top_fill_line)
		let g:meta_fill_line = g:meta_fill_line . " :" . g:block_tags_list[l:tags] . ":"
	let g:meta_fill_line = g:meta_fill_line . " " . g:tag_block_dict[a:line][1]
endfunction

function FindFirstInterviewLine()
	execute "normal! gg"
	let g:tag_search_regex = g:interview_label_regex . '\: \d\{4}'
	let g:first_interview_line = search(g:tag_search_regex, "W")
	call cursor(g:bottom_line, g:bottom_col)
endfunction
	

function CreateBlockMetadataDict() 

	let g:block_metadata             = {}
	let g:tags_on_line               = []
	let g:block_tags_list            = []
	let g:sub_blocks_tags_lists      = []
	#let g:last_match_line = g:match_line
	let g:contiguous_block           = 1
	let g:found_block                = 0
	let g:block_switch               = 0
	let g:continue_searching         = 1
	let g:while_counter              = 0

	call FindFirstInterviewLine()

	#if there are interview lines in the buffer
	if g:first_interview_line > 0
		# find the block range
		while (line('.') >= g:first_interview_line) && (g:continue_searching == 1) && (line('.') > 1)
			call ProcessLineMetadata()
			# Searching to see if we found any tags on line('.')
			# No tags on line, and haven't found block
			if (len(g:block_metadata[line('.')][2]) == 0) && (g:found_block == 0)
				let g:continue_searching = 1
			# Found tags (start of sub-block) and the found_block flag still false
			elseif (len(g:block_metadata[line('.')][2]) != 0) && (g:found_block == 0)
				let g:found_block        = 1
				let g:continue_searching = 1
			# Inside a sub-block
			elseif (len(g:block_metadata[line('.')][2]) != 0) && (g:found_block == 1)
				let g:found_block        = 1
				let g:continue_searching = 1
			# Moved past the found block
			elseif (len(g:block_metadata[line('.')][2]) == 0) && (g:found_block == 1)
				# See if you have the last tag added in the
				# block_tags_list
				if (g:tag_fill_option == "last tag added")
					if (index(g:block_tags_list, g:most_recent_tag_in_changes) != -1)
						let g:continue_searching = 0
						let g:found_block        = 0
					elseif (index(g:block_tags_list, g:most_recent_tag_in_changes) == -1)
						let g:continue_searching = 1
						let g:found_block        = 0
					endif
				else
					let g:continue_searching         = 0 
				endif
			endif
			if g:continue_searching == 1
				execute "normal! k"
			else
				call remove(g:block_metadata, line('.'))
			endif
		endwhile
	else
		call confirm("No interview lines in this buffer",  "OK", 1)
		let g:block_tags_list = []
	endif

	let g:block_tags_list = sort(g:block_tags_list)
endfunction

function CreateSubBlocksLists() 
	let g:sub_blocks_tags_lists = []
	let l:found_block = 0
	for l:line_index in range(str2nr(g:block_lines[0]), str2nr(g:block_lines[-1]))
		if (len(g:block_metadata[l:line_index][2]) != 0) && (l:found_block == 0)
			let g:sub_blocks_tags_lists = g:sub_blocks_tags_lists + [ [ g:block_metadata[l:line_index][2] , [ l:line_index ] ] ]
			let l:found_block        = 1
		# Inside a sub-block
		elseif (len(g:block_metadata[l:line_index][2]) != 0) && (l:found_block == 1)
			# add new tages
			for l:tag_index in range(0, len(g:block_metadata[l:line_index][2]) - 1)
				if (index(g:sub_blocks_tags_lists[-1][0], g:block_metadata[l:line_index][2][l:tag_index]) == -1)
					let g:sub_blocks_tags_lists[-1][0] = g:sub_blocks_tags_lists[-1][0] + [ g:block_metadata[l:line_index][2][l:tag_index] ]
				endif
			endfor
			# add line number
			let g:sub_blocks_tags_lists[-1][1] = g:sub_blocks_tags_lists[-1][1] + [ l:line_index ]
			let l:found_block        = 1
			let g:continue_searching = 1
		# Moved past the found block
		elseif (len(g:block_metadata[l:line_index][2]) == 0) && (l:found_block == 1)
			# See if you have the last tag added in the block_tags_list
			let l:found_block = 0
		endif
	endfor
endfunction

function BuildMetadataBlockFill(id, result) 

	let g:fill_tag = g:block_tags_list[a:result - 1]

	let g:block_lines = sort(keys(g:block_metadata))

	call FindUpperTagFillLine()
	call AddFillTags()
	call CreateSubBlocksLists()

	for l:line_index in range(str2nr(g:block_lines[0]), str2nr(g:block_lines[-1]))
		let g:formatted_metadata = ""

		#Find sub-block and its associated tag list
		for l:sub_block_index in range(0, len(g:sub_blocks_tags_lists) - 1)
			if (index(g:sub_blocks_tags_lists[l:sub_block_index][1], l:line_index) != -1)
				let g:sub_block_tag_list = sort(g:sub_blocks_tags_lists[l:sub_block_index][0])
			endif
		endfor

		for l:tag_index in range(0, len(g:sub_block_tag_list) - 1)
			if (index(g:block_metadata[l:line_index][2], g:sub_block_tag_list[l:tag_index]) != -1)
				let g:formatted_metadata = g:formatted_metadata . " :" . g:sub_block_tag_list[l:tag_index] . ":"
			else
				let g:formatted_metadata = g:formatted_metadata . repeat(' ', len(g:sub_block_tag_list[l:tag_index]) + 3)
			endif
		endfor

		let g:block_metadata[l:line_index] = g:block_metadata[l:line_index] + [ g:formatted_metadata . g:block_metadata[l:line_index][3] ]
		
		let g:block_metadata[l:line_index][4] = substitute(g:block_metadata[l:line_index][4], '\s\+$', '', 'g')
		if g:block_metadata[l:line_index][4] == ""
			let g:block_metadata[l:line_index][4] = "  "
		endif
	endfor
	call WriteInFormattedTagMetadata()
endfunction

function AddFillTags() 
	for l:line_index in range(g:upper_fill_line + 1, str2nr(g:block_lines[-1]))
		let g:block_metadata[l:line_index][2] = g:block_metadata[l:line_index][2] + [ g:fill_tag ]
		let g:block_metadata[l:line_index][2] = sort(g:block_metadata[l:line_index][2]) 
	endfor
endfunction

function FindUpperTagFillLine() 
	for l:line_index in range(str2nr(g:block_lines[0]), str2nr(g:block_lines[-1]))
		if (index(g:block_metadata[l:line_index][2], g:fill_tag) != -1)
			let g:upper_fill_line = l:line_index
		endif
	endfor
endfunction

function WriteInFormattedTagMetadata() 
	set virtualedit=all
	for l:line_index in range(str2nr(g:block_lines[0]), str2nr(g:block_lines[-1]))
		call cursor(l:line_index, 0)
		execute "normal! " . g:block_metadata[l:line_index][1] . "|lv$dh"
		execute "normal! a" . g:block_metadata[l:line_index][4] . "\<ESC>"

	endfor
	set virtualedit=""

	call cursor(g:bottom_line, g:bottom_col)
	execute "normal! zzA "
endfunction

function ProcessLineMetadata() 
	let g:tags_on_line            = []
	let g:non_tag_metadata        = ""

	set virtualedit=all
	execute "normal! 0Vygv/│\<CR>/│\<CR>\<ESC>"
	let g:right_border_col     = col('.')
	let g:right_border_virtcol = virtcol('.')
	set virtualedit=""
	let g:block_metadata[line('.')] = [ g:right_border_col , g:right_border_virtcol ]
	
	# copy everything beyond the right of the right label pane border.
	execute "normal! lv$y"
	#execute "normal! lvg_y"
	# Tokenize what got copied into a list called g:line_meta_data
	let g:line_metadata = split(@@)
	for l:index in range(0, len(g:line_metadata) - 1)
		if (match(g:line_metadata[l:index], ':\a.\{-}:') != -1)
			let g:tags_on_line = g:tags_on_line + [ g:line_metadata[l:index][1:-2] ]
			if (index(g:block_tags_list, g:line_metadata[l:index][1:-2]) == -1)
				let g:block_tags_list = g:block_tags_list + [ g:line_metadata[l:index][1:-2] ]
			endif
		else
			let g:non_tag_metadata = g:non_tag_metadata . " " . g:line_metadata[l:index]
		endif
	endfor
	let g:block_metadata[line('.')] = g:block_metadata[line('.')] + [ g:tags_on_line , g:non_tag_metadata ]
endfunction

# ------------------------------------------------------
#
# ------------------------------------------------------
function ChangeTagFillOption() 
	if (!exists("g:tag_fill_option"))
		let g:tag_fill_option = "last tag added"
		call confirm("Default tag presented when F5 is pressed will be the last tag added to the buffer.",  "OK", 1)
	elseif (g:tag_fill_option == "last tag added")
		let g:tag_fill_option = "bottom of contiguous block"
		call confirm("Default tag presented when F5 is pressed will be the last tag in the contiguous block above the cursor.",  "OK", 1)
	elseif (g:tag_fill_option == "bottom of contiguous block")
		let g:tag_fill_option = "last tag added"
		call confirm("Default tag presented when F5 is pressed will be the last tag added to the buffer.",  "OK", 1)
	endif
endfunction


# ------------------------------------------------------
#
# ------------------------------------------------------
function SortTagDefs() 
	execute "normal! :%s/}/}\\r/g\<CR>"
	execute "normal! :g/{/,/}/s/\\n/TTT\<CR>"
	execute "normal! :3,$sort \i\<CR>"
	execute "normal!" .':3,$g/^$/d' . "\<CR>"
	execute "normal! :%s/TTT/\\r/g\<CR>"
endfunction


# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function GetTagDef() 
	
	call ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Find the tag under the cursor. If it exists in the tag_dict display
	# the definition in a popup window, else offer to add the tag to the
	# Tag Glossary page.
	# -----------------------------------------------------------------
	let g:tag_to_test = GetTagUnderCursor()
 	if (g:tag_to_test != "") 
		if (has_key(g:tag_dict, g:tag_to_test))
 			call popup_atcursor(get(g:tag_dict, g:tag_to_test), {
 				\ 'border': [],
 				\ 'close' : 'click',
 				\ })
 		else
 			call popup_menu(["Yes", "No"], #{
			        \ title: "\"" . g:tag_to_test . "\" is not defined in the Tag Glossary. Would you like to add it now?", 
				\ callback: 'AddNewTagDef' ,
				\ highlight: 'Question'    ,
 				\ border: [],
 				\ close : 'click',
				\ padding: [0,1,0,1],
 				\ })
		endif
	else
 		call popup_atcursor("There is no valid tag under the cursor.", {
 			\ 'border': [],
 			\ 'close' : 'click',
 			\ })
 	endif
endfunction


# -----------------------------------------------------------------
# See if word under cursor is a tag. ie. a word surrounded by colons
# Test case where the cursor is on white space.
# -----------------------------------------------------------------
function GetTagUnderCursor() abort        
	execute "normal! viWy"        
	let l:word_under_cursor             = @@ 
	# Want tag_test to be 0
	let l:tag_test                      = matchstr(l:word_under_cursor, ':.\{-}:')
	# -----------------------------------------------------------------
	# Test to see if g:word_under_cursor is just white space. If not,
	# test to see if the word_under_cursor is surrounded by colons.
	# -----------------------------------------------------------------
	if l:word_under_cursor == l:tag_test
		return l:word_under_cursor[1:-2]
	else
		return ""
	endif
endfunction

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
function AddNewTagDef(id, result) 
	if a:result == 1
		# -----------------------------------------------------------------
		# Save buffer number of current file to register 'a' so you can return here
		# -----------------------------------------------------------------
		execute "normal! :delmarks Z\<CR>"
		execute "normal! mZ"
		# -----------------------------------------------------------------
		# Go to Tag Glossary and create a new tag template populated with the 
		# g:tag_to_test value
		# -----------------------------------------------------------------
		execute "normal! :e Tag Glossary" . g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] . "\<CR>"
		execute "normal! Go{\n## Name: " . g:tag_to_test . "\n**Detailed Description:** \n**Incl. Criteria:** \n**Excl. Criteria:** \n**Example:** \n}\<ESC>4kA"
		call SortTagDefs()
		execute "normal! /Name: " . g:tag_to_test . "\<CR>jA"
		call confirm("Add your tag description.\n\nWhen you are finished press <F2> to update the tag list.\n\n", "OK", 1)
	endif
endfunction

# -----------------------------------------------------------------
# ---------------------------- ATTRIBUTES -------------------------
# -----------------------------------------------------------------

# ------------------------------------------------------

# ------------------------------------------------------
function Attributes(sort_col = 1) 
	
	call ParmCheck()

	# from the buffer which should be the line of the interview attribute
	# tags. We're going to build our output in two reg
	let g:attrib_chart = ""
	let g:attrib_csv   = ""
	# from the buffer which should be the line of the interview attribute
	# tags. We're going to build our output in two reg
	let g:attrib_chart = ""
	let g:attrib_csv   = ""
	call GetInterviewFileList()

	# save buffer number of current file to register 'a' so you can return here
	let @a = bufnr('%')
	# go through the list of files copying and processing the first line
	# from the buffer which should be the line of the interview attribute
	# tags. We're going to build our output in two reg
	let g:attrib_chart = ""
	let g:attrib_csv   = ""
	for interview in range(0, (len(g:interview_list) - 1))
		# go to interview file
		execute "normal :e " . g:interview_list[interview] . "\<CR>"
		# copy first row which should be the attribute tags.
		execute "normal! ggVy"
		let g:attribute_row = @@
		# format the attribute tags for the chart and for the csv
		let g:interview_label = "| [[" . g:interview_list[interview][:-4] . "]]"
		let g:attrib_chart_line = substitute(g:attribute_row, ": :", "|", "g")
		let g:attrib_chart_line = substitute(g:attrib_chart_line, ":", "|", "g")
		let g:attrib_chart_line = g:interview_label . g:attrib_chart_line
		let g:attrib_chart = g:attrib_chart . g:attrib_chart_line
	endfor
	# return to page where you're going to print the chart and paste the
	# chart.
	execute "normal! :b\<C-R>a\<CR>gg"
	execute "normal! ggVGd"
	execute "normal! i" . g:attrib_chart . "\<CR>"
	execute "normal! Go\<ESC>v?.\<CR>jdgga\<ESC>\<CR>gg"
	call ColSort(a:sort_col)
endfunction

# ------------------------------------------------------

# ------------------------------------------------------
# ------------------------------------------------------
# Sort the Attribute table by column number
# ------------------------------------------------------
function ColSort(column) 
	let g:sort_regex = "/\\(.\\{-}\\zs|\\)\\{" . a:column . "}/"
	execute "normal! :sort " . g:sort_regex . "\<CR>"
endfunction

# -----------------------------------------------------------------
# ---------------------------- OTHER ------------------------------
# -----------------------------------------------------------------

# ------------------------------------------------------
#
# ------------------------------------------------------
function UpdateSubcode() 
	
	call ParmCheck()

	# -----------------------------------------------------------------
	# Clear @@ register.
	# -----------------------------------------------------------------
	let @@ = ""
	# -----------------------------------------------------------------
	# Process the first case.  Initialise list
	# -----------------------------------------------------------------
	let g:subcode_list = []
	# -----------------------------------------------------------------
	# VWS to get search results and open location list
	# -----------------------------------------------------------------
	execute "normal! :VWS " . '/ _\w\{1,}/' . "\<CR>"
	execute "normal! :lopen\<CR>"	
	# -----------------------------------------------------------------
	# Add first search result to list
	# -----------------------------------------------------------------
	let g:is_search_result = search(' _\w\{1,}', "W")
	if (g:is_search_result != 0)
		execute "normal! lviwyel"
		let g:subcode_list = g:subcode_list + [@@]	
		while (g:is_search_result != 0)
			let g:is_search_result = search(' _\w\{1,}', "W")
			if (g:is_search_result != 0)
				execute "normal! lviwyel"
				let g:subcode_list = g:subcode_list + [@@]
			endif 
		endwhile
	endif
	# -----------------------------------------------------------------
	# Need to change the list to a string so it can be pasted into a
	# buffer.
	# -----------------------------------------------------------------
	let g:subcode_list_as_string = string(g:subcode_list)
	# -----------------------------------------------------------------
	# Open new buffer; delete its contents and replace them with
	# g:subcode_list_as_a_string; sort the buffer keeping unique values
	# and delete the top line which is a blank line; save the file writing
	# over top of what's there (!); close the Location List and close the
	# 'new' buffer without saving. (You saved the content of this buffer
	# to a file.
	# -----------------------------------------------------------------
	execute "normal! :sp new\<CR>"
	execute "normal! ggVGd:put=" . g:subcode_list_as_string . "\<CR>"
	execute "normal! :sort u\<CR>dd"
	execute "normal! :w! "  . g:subcode_dictionary_path . "\<CR>"
	execute "normal! \<C-w>k:lclose\<CR>\<C-w>j:q!\<CR>"
endfunction

function CorrectAttributeLines() 
	
	call ParmCheck()

	# Change the pwd to that of the current wiki.
	execute "normal! :cd %:p:h\<CR>"
	# get a list of all the files and directories in the pwd. note the
	# fourth argument that is 1 makes it return a list. the first argument
	# '.' means the current directory and the second argument '*' means
	# all.
	let g:file_list_all = globpath('.', '*', 0, 1)
	# build regex we'll use just to find our interview files. 
	let g:file_regex = g:interview_label_regex . '.md'
	#  cull the list for just those files that are interview files. the
	#  match is at position 2 because the globpath function prefixes
	#  filenames with ./ which occupies positions 0 and 1.
	let g:interview_list = []
	for list_item in range(0, (len(g:file_list_all) - 1))
		if (match(g:file_list_all[list_item], g:file_regex) == 2) 
			# strip off the leading ./
			let g:file_to_add = g:file_list_all[list_item][2:]
			let g:interview_list = g:interview_list + [g:file_to_add]
		endif
	endfor
	# save buffer number of current file to register 'a' so you can return here
	let @a = bufnr('%')
	# go through the list of files copying modifying the attribute line.
	for interview in range(0, (len(g:interview_list) - 1))
		# go to interview file
		execute "normal :e " . g:interview_list[interview] . "\<CR>"
		# copy first row which should be the attribute tags.
		execute "normal! :1,1s/:/: :/g\<CR>"
		execute "normal! :1,1s/^: :/:/\<CR>"
		execute "normal! :1,1s/: :$/:/\<CR>"
	endfor
endfunction

function Fix() 
		execute "normal! :1,1s/:/: :/g\<CR>"
		execute "normal! :1,1s/^: :/:/\<CR>"
		execute "normal! :1,1s/: :$/:/\<CR>"
endfunction

function CreateBlockMetadataDictOLD() 
	# Read back from where the tag is and copy the tags you find into a
	# list (one for each line in the block). Sort each line's tags and add
	# create a tag list for the whole block. You have this code. Also add
	# in the tag to be filled into the main list. Sort all the tags.
	# Delete the tags from the block as you go because you'll add them
	#redraw!
	#lazyredraw
	
	# back in in an aligned format.
	let g:tags_on_line    = []
	#let g:last_match_line = g:match_line

	# -----------------------------------------------------
	# Find tags in lines above and add them to a list until the there is a gap between the lines with tags
	# Search for first match the bW means search backwards and don't wrap around the end of the file.
	# -----------------------------------------------------
	let g:match_line              = search(':\a.\{-}:', 'bW')
	# -----------------------------------------------------
	#  As long as we find a match (ie the result of the search function is
	#  not equal to zero) that is not the attribute line (1) continue.
	#  ----------------------------------------------------
	if (g:match_line <= 1)
		call cursor(g:bottom_line, g:bottom_col)
		call confirm("No tags found above the cursor",  "OK", 1)
	else
		# ----------------------------------------------------------
		# Now we're going to look for the rest of the tags in a
		# contiguously tagged block above where the cursor is.
		# ----------------------------------------------------------
		let g:current_match_line      = line('.')
		let g:last_match_line         = g:match_line
		# ----------------------------------------------
		# Copy the first found tag and add it to the matched-tag-list. 
		# ----------------------------------------------
		call ProcessLineWithTags()
		let g:last_match_line = g:match_line
		# -----------------------------------------------------------
		# Set an is-contiguous-tag-block boolean to true (1).
		# -----------------------------------------------------------
		let g:is_contiguous_tagged_block = 1
		while (g:is_contiguous_tagged_block == 1)
			# --------------------------------------------------
			# Search backwards ('b') for another tag.
			# --------------------------------------------------
			let g:match_line = search(':\a.\{-}:', 'bW')
			# If there is a tag in a contiguous block
			if (g:match_line > 1) 
				if (g:last_match_line - g:match_line == 1)
					call ProcessLineWithTags()
					let g:last_match_line = g:match_line
				else
					let g:is_contiguous_tagged_block = 0
				endif
			else
				let g:is_contiguous_tagged_block = 0
			endif
		endwhile	
	endif
if (g:tag_fill_option == "last tag added")
		if (index(g:block_tags_list, g:most_recent_tag_in_changes) == -1)
			let g:tag_list_to_present =  [ g:most_recent_tag_in_changes ] + g:block_tags_list
		else 
			let g:tag_list_to_present = g:block_tags_list 
		endif
	elseif (g:tag_fill_option == "bottom of contiguous block")
		let g:tag_list_to_present = g:block_tags_list 
	endif
	let g:block_tags_list = sort(g:block_tags_list)
endfunction
