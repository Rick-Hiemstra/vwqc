vim9script

#if !has('vim9script') ||  v:version < 901
#    echoerr 'Needs Vim version 9.1 and above'
#    finish
#endif
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
# Add thevwqc key-value pair to the wiki definitions.
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
#var g:tag_dict                  = {}
#var g:current_tags              = []
#var g:loc_list                  = []

# ------------------------------------------------------
# Displays a popup help menu
# ------------------------------------------------------
def HelpMenu()
	var help_list = [             "NAVIGATION", 
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
	popup_menu(help_list , 
				 { minwidth: 50,
				 maxwidth: 100,
				 pos: 'center',
				 border: [],
				 close: 'click',
				 })
enddef

# ------------------------------------------------------
# This sets up a project from a blank Vimwiki index page
# ------------------------------------------------------

def g:ProjectSetup() 
	execute "normal! gg"
	g:index_page_content_test = search('\S', 'W')
	if (g:index_page_content_test != 0)
		var index_already_created = "The index page already has content.\n\nSetup not performed."
		confirm(index_already_created,  "OK", 1)
	else
		execute "normal! O## <Project Title> ##\n\n[Tag Glossary](Tag Glossary)\n[Tag List Current](Tag List Current)\n"
		execute "normal! i[Attributes](Attributes)\n[Style Guide](Style Guide)\n\n## Interviews ##\n"
		execute "normal! i\no = Needs to be coded; p = in process; x = first pass done; z = second pass done\n\n"
		execute "normal! i[o] \n[o] \n[o] \n[o] \n\n## Tag Summaries ##\n\n"

		GetVWQCProjectParameters()

		mkdir(g:extras_path, "p")
		mkdir(g:tag_summaries_path, "p")
		mkdir(g:backup_path, "p")

		var extras_path_creation_message = "A directory for additional project files has been created at:\n\n" .. g:extras_path
		confirm(extras_path_creation_message,  "OK", 1)

		var backup_path_creation_message = "A directory for project backups has been created at:\n\n" .. g:backup_path
		confirm(backup_path_creation_message,  "OK", 1)

		var tag_summaries_path_creation_message = "A directory for CSV tag summaries has been created at:\n\n" .. g:tag_summaries_path .. "\n\nFiles will appear here after you create summary reports"
		confirm(tag_summaries_path_creation_message,  "OK", 1)

		CreateDefaultInterviewHeader()
	       	var template_message       = "A default interview header template has been created here:\n\n" .. g:int_header_template .. "\n\nModify it to your project's specifications before formatting interviews."
		confirm(template_message,  "OK", 1)
	endif
enddef

# -----------------------------------------------------------------
# This function creates a simple default interview header
# -----------------------------------------------------------------
def CreateDefaultInterviewHeader() 
	if (filereadable(g:int_header_template) == 0) 
                # leave a space at the beginning of the list of attributes. It
		# affects how the first attribute tag is found.
		var template_content = " :<attribute_1>: :<attribute_2>: :<attribute_3>:\n" ..
					 "\n" ..
					 "First pass:  \n" ..
       				         "Second pass: \n" ..
       				         "Review: \n" ..
       				         "Handwritten interview notes: [[file:]]\n" ..
       				         "Audio Recording: [[file:]]\n" ..
       				         "\n" ..  
       				         "====================\n" .. 
					 "\n" 
 		
		writefile(split(template_content, "\n", 1), g:int_header_template) 
	endif
enddef

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

	g:backup_path = substitute(g:vimwiki_wikilocal_vars[g:wiki_number]['path'], '[^\/]\{-}\/$', "", "g") .. g:project_name .. " Backups/"

	# If header template location is explicitly defined then use it, otherwise use default file.
	var has_template = 0
	#has_template = has_key("g:" ..  g:current_wiki_name .. ", 'interview_header_template')\<CR>"
	execute "normal! :let has_template = has_key(g:" ..  g:current_wiki_name .. ", 'interview_header_template')\<CR>"
	if (has_template == 1) 
		execute "normal! :let g:vimwiki_wikilocal_vars[g:wiki_number]['interview_header_template'] = g:" .. g:current_wiki_name .. ".interview_header_template\<CR>" 
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
	execute "normal! :let has_tag_sum_path = has_key(g:" ..  g:current_wiki_name .. ", 'tag_summaries')\<CR>"
	if (has_tag_sum_path == 1)
		execute "normal! :let g:vimwiki_wikilocal_vars[g:wiki_number]['tag_summaries'] = g:" .. g:current_wiki_name .. ".tag_summaries\<CR>" 
		g:tag_summaries_path       = expand(g:vimwiki_wikilocal_vars[g:wiki_number]['tag_summaries'])
	else
		g:tag_summaries_path       = expand(g:extras_path .. "tag_summaries/")
	endif

	g:glossary_path                    = g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. "Tag Glossary.md"

	var has_coder = 0
	execute "normal! :let has_coder = has_key(g:" .. g:current_wiki_name .. ", 'coder_initials')\<CR>"
	if (has_coder)
		execute "normal! :let g:vimwiki_wikilocal_vars[g:wiki_number]['coder_initials'] = g:" .. g:current_wiki_name .. ".coder_initials\<CR>" 
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
def g:ListProjectParameters() 

	ParmCheck()
			
	var base0                = "Base 0 wiki #        " .. g:wiki_number
	var base1                = "Base 1 wiki #        " .. g:wiki_number_plus_1
	var list_path            = "Path:                " .. g:vimwiki_wikilocal_vars[g:wiki_number]['path']
        var list_ext		 = "Ext:                 " .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
	var list_regex           = "Label regex:         " .. g:interview_label_regex
	var list_text_width      = "Text col width:      " .. g:text_col_width
	var list_border_offset   = "Label border col:    " .. g:border_offset
	var list_header_template = "Header template:     " .. g:int_header_template
	var list_tag_summaries   = "Tag summaries:       " .. g:tag_summaries_path
	var list_subcode         = "Sub-code dictionary: " .. g:subcode_dictionary_path
	var list_glossary        = "Tag glossary:        " .. g:glossary_path
	var list_coder           = "Coder initials:      " .. g:coder_initials
 	
	g:vwqc_proj_parm_list =    ["CURRENT PROJECT CONFIGURATION", 
		                         " ", 
					 base0,
					 base1,
					 " ",
					 list_path,
					 list_ext,
					 list_regex,
					 list_text_width,
					 list_border_offset,
					 list_header_template,
					 list_tag_summaries,
					 list_subcode,
					 list_glossary,
					 list_coder]
	popup_menu(g:vwqc_proj_parm_list, 
				 { minwidth: 50,
				 maxwidth: 250,
				 pos: 'center',
				 border: [],
				 close: 'click', })

enddef

def DoesFileNameMatchLabelRegex(test_value: string): number
	if (match(test_value, g:interview_label_regex) == 0)
		return 1
	else
		return 0
	endif
enddef

def g:FormatInterview(label = "default") 
	var valid_label_test    = 0
	var proposed_label      = ""
	var file_label_mismatch_warning = "Warning not set"
	var bad_label_error_message = "Warning not set"

	if (label == "default")
		valid_label_test    = DoesFileNameMatchLabelRegex(expand('%:t:r'))
		proposed_label      = expand('%:t:r')
	else
		valid_label_test = DoesFileNameMatchLabelRegex(label)
		proposed_label = label
	endif

	if (valid_label_test)
		if (proposed_label != expand('%:t:r'))
			file_label_mismatch_warning = proposed_label .. " does not match the " .. expand('%:t:r') .. " file name."
			confirm(file_label_mismatch_warning, "Got it", 1)
		endif
		FormatInterviewB(proposed_label)
	else
		bad_label_error_message = proposed_label .. " does not conform to the " .. g:vimwiki_wikilocal_vars[g:wiki_number]['interview_label_regex'] .. " label regular expression from the VWQC configuration. " .. "Interview formatting aborted."	
		confirm(bad_label_error_message, "Got it", 1)
	endif
enddef

# -----------------------------------------------------------------
# This function formats interview text to use in for Vimwiki interview coding. 
# -----------------------------------------------------------------
def g:FormatInterviewB(interview_label: string) 

	ParmCheck()

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
		setline(line, substitute(getline(line), '\[\(\d:\d\d:\d\d\)\]', '\(\1\)', 'g'))
        endfor
	# -----------------------------------------------------------------
	# These next few lines add a fixed end of line at the column specified in the 
	# wiki configuration. The first line turns on virtualedit mode. This allows you to select columns outside the
	# range of your line. The second line just selects the first column. 
	# The third line overwrites the content added in the second line with 
	# pipe symbols. The final line turns virtualedit mode off.
	# -----------------------------------------------------------------
	set virtualedit=all
	execute "normal! gg\<C-v>Gy" .. g:border_offset_less_one .. "|p"
	execute "normal! gg" .. g:border_offset .. "|\<C-v>G" .. g:border_offset .. "|r│"
	set virtualedit=none	
	# -----------------------------------------------------------------
	# Reposition cursor at the top of the buffer
	# -----------------------------------------------------------------
	execute "normal! gg"
	# -----------------------------------------------------------------
	# Add labels at the end of the line using the label passed into the 
	# function as an argument.
	# -----------------------------------------------------------------
	for line in range(1, line('$'))
		cursor(line, 0)
		execute "normal! A " .. interview_label .. "\: \<ESC>"
	endfor
	# -----------------------------------------------------------------
	# Add line numbers to the end of each line and the second
	# column of double pipe symbols
	# -----------------------------------------------------------------
	for line in range(1, line('$'))
		g:line_number_to_add = printf("%04d │ ", line)
		setline(line, substitute(getline(line), '$', g:line_number_to_add, 'g'))
        endfor
	# -----------------------------------------------------------------
	# Reposition cursor at the top of the buffer and add header template.
	# -----------------------------------------------------------------
	execute "normal! gg"
	execute "normal! :.-1read " .. g:int_header_template .. "\<CR>gg"
enddef

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
def g:PageHelp() 

	ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Find the current file name
	
	g:current_buffer_name = expand('%:t')
	g:is_interview        = match(g:current_buffer_name, g:interview_label_regex)
	g:is_annotation       = match(g:current_buffer_name, g:interview_label_regex .. ': \d\d\d\d')
	g:is_summary          = match(g:current_buffer_name, 'Summary ')

	if g:current_buffer_name == "index" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		g:page_help_list = [              
			        "INDEX HELP PAGE", 
		                "The index page is your project home page. You can return to this page by typing <leader>ww in normal mode.",
		                "From here you can create new pages for interviews or summary pages.",
		                " ",
		                "Summary pages, pages that summarize specific tags, must begin with the word \"Summary\" .. ",
		                "Interview pages must be named according to the regular expression (regex) defined in your project parameters. ",
		                "Press <leader>lp in normal mode to list project parameters. ",
		                " ",
			        "Click on this window to close it"]
		DisplayPageHelp()
	elseif g:current_buffer_name == "Attributes" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		g:page_help_list = [              
			        "ATTRIBUTES HELP PAGE", 
		                "The \"Attributes\" page lists the interview attributes which are the tags that appear on the first line of",
		                "each interview page. ",
		                " ",
		                "You can update this page by running the following command in normal mode: ",
		                " ",
		                ":call Attributes() ",
		                " ",
		                "These attributes can be sorted by running the Attributes() command with the column number to sort on.",
		                "For example, the following command sorts on the third column:",
		                " ",
		                ":call Attributes(3) ",
		                " ",
			        "Click on this window to close it"]
		DisplayPageHelp()
	elseif g:current_buffer_name == "Tag List Current" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		g:page_help_list = [              
			        "TAG LIST CURRENT HELP PAGE", 
		                "This lists current project tags. It is generated or updated by pressing F2",
		                " ",
			        "Click on this window to close it"]
		DisplayPageHelp()
	elseif g:current_buffer_name == "Tag Glossary" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		g:page_help_list = [              
			        "TAG GLOSSARY HELP PAGE", 
		                "Tag definitions can be added here manually, but they are best added by placing the cursor over a valid tag in an ", 
			        "interview page in normal mode and pressing <leader>df. This will start a dialogue that will allow you to add a tag", 
			        "definition. When you are finished defining your tag you can press F2 to update the tag list and <leader>gb to ", 
				 "return to where you were coding.",
		                " ",
			        "Tag definitions must be inside brace brackets {} and the tag name must be the last word on the first line inside the",
		                "brace brackets. The format is flexible but it is recommended that you use the form that is pre-populated when you use",
		                "the dialogue that is initiated when you press <leader>df while your cursor is on a tag and you are in normal mode.",
		                " ",
			        "Click on this window to close it"]
		DisplayPageHelp()
	elseif g:is_annotation == 0
		g:page_help_list = [              
			        "ANNOTATION HELP PAGE", 
		                "Use F7 to toggle an annotation page open and closed",
		                " ",
			        "Click on this window to close it"]
		DisplayPageHelp()
	elseif g:is_interview == 0
		g:page_help_list = [              
			        "INTERVIEW HELP PAGE", 
		                "",
			        "Interview pages are split into four parts or panes:",
			        "",
			        "1) The header",
			        "2) The interview pane",
			        "3) The line-label pane",
			        "4) The coding pane",
			        "",
			        "Interview pages are populated by initally pasting the interview text into a blank page ",
			        "that has been named according to the label regular expression (regex) you used for the",
			        "project configuration (i.e. /d/d-/w-/w/w/w/w). The pasted interview text is formatted ",
			        "with the FormatInterview() function. i.e.",
			        "",
			        ":call FormatInterview()",
			        "",
			        "Annotations are added by pressing F7 on the line where you want to add an annotation.",
			        "This will open an annotation window on the right-hand side of your screen placing you",
			        "directly in insert mode. Annotation windows can be closed by pressing F7 again.",
			        "",
			        "Tags (codes) are contiguous words beginning with a letter and surrounded by colons.",
			        "For example :family: or :child:. Each line can have multiple tags, but tags must",
			        "be separated by a space.",
			        "",
			        "Interviews are coded line-wise. This means that each line in a block of code must ",
			        "be coded, not just the starting and ending lines. Usually, an interview will be ",
			        "coded from top to bottom. ",
			        "",
			        "There are several ways VWQC helps facilitated coding. First, it provides tag ",
			        "omni-completion. Second, it provides keybindings to fill tags from the bottom of ",
			        "code block up to the top.",
		                "",
		                "If you start typing a tag (i.e. a colon followed by one or more characters) and press",
		                "F8 (or F9) an omni-completion menu will pop up with a list of tags that begin with the",
		                "prefix you just typed. You can use the arrow keys to make your selection and then finish",
		                "the tag entry with your closing colon character.",
		                "",
		                "Block completion looks above the cursor for tag completion candidates. VWQC tries to ",
		                "anticipate which tag you want to fill up from your cursor position to make a code block.",
		                "If there is only one tag in the contiguous code block above your cursor then VWQC will fill",
		                "in that tag. Otherwise you are presented with a menu of tag choices pulled from the first",
		                "contiguous code block above the cursor. This menu is generated in one of two modes. The first",
		                "mode presents the last tag added to the buffer as the default tag. The default tag can be ",
		                "selected by simply pressing enter. The second mode presents the first tag above the cursor as",
		                "the default tag. The current tag-fill mode will be indicated in the pop-up menu title. The mode",
		                "can be changed with the F4 toggle.",
		                "",
		                "An annotation associated with a line can be created with the F7 key. This will open an annotation",
		                "window to the right of your screen. This annotation window can be closed by pressing F7 again.",
		                "If you want to remove an annotation, place your cursor on the line in an interview page where it",
		                "is called (not in the annotation page itself) and, in normal mode, press <leader>da and this will",
		                "initiate a dialogue that will allow you to delete the annotation.",
		                "",
			        "Click on this window to close it"]
		DisplayPageHelp()
	elseif g:is_summary == 0
		g:page_help_list = [              
			        "SUMMARY HELP PAGE", 
				 ":call FullReport(\"<tag>\")           Create report with tagged and annotation content",
				 ":call QuotesReport(\"<tag>\")         Create report with just tagged content",
				 ":call MetaReport(\"<tag>\")           Create the FullReport with all line metadata",
				 ":call VWSReport(\"<string>\")         Create custom search report", 
		                " ",
		                "Quoted lines can also be recoded within a report. These re-codings",
		                "can then be \"gathered\" into a sub-report. Add new codes to the end",
		                "of lines. Then place your cursor below the count table near the top of",
		                "the report. Run the following command to create the re-coded report.",
		                "",
		                ":call Gather(\"<tag>\")",
		                "",
		                "Line-wise coding means that there are usually residual tails and heads",
		                "from sentences before and after the text you meant to code or tag. In a ",
		                "summary report, you can place your cursor on an interview line and press",
		                "<leader>tt to trim the tail of your quote, and <leader>th to trim the head.",
		                "If you want to trim both the head and tail you can use <leader>ta.",
		                "",
			        "Click on this window to close it"]
		DisplayPageHelp()
	endif

enddef

def DisplayPageHelp() 
	popup_menu(g:page_help_list, 
			 { minwidth: 50,
			 maxwidth: 150,
			 pos: 'center',
			 border: [],
			 close: 'click',
			 })
enddef

# -----------------------------------------------------------------
#
# -----------------------------------------------------------------
def g:CreateBackupQuery() 

	ParmCheck()

	var today              = strftime("%Y-%m-%d")
	var time_now           = strftime("%H-%M-%S")
	 
	g:backup_path          = substitute(g:vimwiki_wikilocal_vars[g:wiki_number]['path'], '[^\/]\{-}\/$', "", "g") .. g:project_name .. " Backups/"
	g:backup_folder_name   = today .. " at " .. time_now .. " Backup by " .. g:coder_initials .. "/"
	g:new_backup_path      = g:backup_path .. g:backup_folder_name
	g:backup_list          = globpath(g:backup_path, '*', 0, 1)

	if len(g:backup_list) > 0
		g:last_backup        = substitute(g:backup_list[-1], g:backup_path, "", "g")
		g:backup_message     = "The last backup was: " .. g:last_backup .. ". Make a new backup now?"
	else
		g:backup_message     = "No backups found. Make a backup now?"
	endif
			
	popup_menu(["Yes", "No"], {
		 title:    g:backup_message,
		 callback: 'CreateBackup', 
		 highlight: 'Question',
		 border:     [],
		 close:      'click', 
		 padding:    [0, 1, 0, 1] })
enddef

# -----------------------------------------------------------------
#
# -----------------------------------------------------------------
def CreateBackup(id: number, result: number) 
	var backup_message = "Backup message not set."

	if result == 1
		#Save current buffer so it doesn't matter if we delete copied
		#swap files.
		execute "normal! :w\<CR>"
		mkdir(g:new_backup_path, "p")
		g:copy_command  = 'cp -R "'. g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. '" "' .. g:new_backup_path .. '"'
		g:clean_up_swo = 'rm -f "'. g:new_backup_path .. '"' .. '.*.swo'
		g:clean_up_swp = 'rm -f "'. g:new_backup_path .. '"' .. '.*.swp'
		g:clean_up_swn = 'rm -f "'. g:new_backup_path .. '"' .. '.*.swn'
		system(g:copy_command)
		system(g:clean_up_swo)
		system(g:clean_up_swp)
		system(g:clean_up_swn)
		backup_message 	   = "A new back up has been created at: " .. g:new_backup_path
	else
		backup_message     = "Backup not created."		
	endif
	
	confirm(backup_message,  "OK", 1)
	
enddef

# -----------------------------------------------------------------
# --------------------------- NAVIGATION  -------------------------
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# One of three annotation functions. This first one opens an annotation window.
# If it is a new window it names it using the label from line from which it is
# called, adds a title label and the coders initials.
# -----------------------------------------------------------------
def Annotation() 
	
	ParmCheck()

	# -----------------------------------------------------------------
	#  Find the tags on the line this function is called from.
	# -----------------------------------------------------------------
	g:list_of_tags_on_line = ""
	g:is_tag_on_line = 1
	g:current_line = line(".")
	execute "normal! 0"
	# -----------------------------------------------------------------
	# Loop until no more tags are found on the line.
	# -----------------------------------------------------------------
	while (g:is_tag_on_line == 1)
		# --------------------------------------------------
		# Search for a tag without going past the end of the file.
		# --------------------------------------------------
		g:match_line = search(':\a.\{-}:', "W")
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
			g:this_tag = @@
			g:list_of_tags_on_line = g:list_of_tags_on_line .. g:this_tag .. " "
		else
			# No more tags
			g:is_tag_on_line = 0
		endif 
	endwhile	
	# -----------------------------------------------------------------
	# Move cursor back to the start of current_line because the search
	# function may have moved the cursor beyond current_line
	# -----------------------------------------------------------------
	cursor(g:current_line, 0)
	execute "normal! 0"
	# -----------------------------------------------------------------
	# Initialize variables and move cursor to the beginning of the line.
	# -----------------------------------------------------------------
	g:match_line = 0
	g:match_col = 0
	# -----------------------------------------------------------------
	# Search for the label - number pair on the line. searchpos() 
	# returns a list with the line and column numbers of the cursor
	# position of the first character in the match. searchpos() with
	# the arguments we supplied will move the cursor to the first
	# character of match we found. So because we started in column 1
	# if the column remains at 1 we know we didn't find a match.
	# -----------------------------------------------------------------
	g:tag_search_regex = g:interview_label_regex .. '\: \d\{4}'
	g:tag_search = searchpos(g:tag_search_regex)
	g:match_line = g:tag_search[0]
	g:match_col  = virtcol('.')
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
		g:current_window_width = winwidth('%')
		g:annotation_window_width = g:current_window_width - g:border_offset - 45
		if g:annotation_window_width < 30
			g:annotation_window_width = 30
		elseif g:annotation_window_width > 80
			g:annotation_window_width = 80
		endif
		# ------------------------------------------------------------------
		#  Figure out which version of Vim or NeoVim we're running.
		#  Older versions have a different vsplit behavior. The first
		#  test is for Vim and the second for NeoVim. has() returns a
		#  1 for true or 0 for false.
		# ------------------------------------------------------------------
		if has('nvim') && has('patch-0-6-0')
			g:new_vsplit_behaviour = 1
		elseif has('patch-8.2.3832')
			g:new_vsplit_behaviour = 1
		else
			g:new_vsplit_behaviour = 0
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
			execute "normal! " .. '0/' .. g:interview_label_regex .. '\:\s\{1}\d\{4}' .. "\<CR>" .. 'vf│hhy'
			execute "normal! gvc[]\<ESC>F[plli()\<ESC>\"\"P\<ESC>" 
			execute "normal \<Plug>VimwikiVSplitLink"
			if g:new_vsplit_behaviour 
				execute "normal! \<C-W>x\<C-W>l:vertical resize " .. g:annotation_window_width .. "\<CR>"
			else
				execute "normal! \<C-W>x\<C-W>l:vertical resize " .. g:annotation_window_width .. "\<CR>"
			endif
			put =expand('%:t')
			execute "normal! 0kdd/.md\<CR>xxxI:\<ESC>2o\<ESC>"
			g:current_time = strftime("%Y-%m-%d %H\:%M")
		        execute "normal! i[" .. g:current_time .. "] " .. g:list_of_tags_on_line .. "// \:" .. g:coder_initials .. "\:  \<ESC>"
			startinsert 
		elseif g:match_col == (g:label_offset + 1)
			# -----------------------------------------------------------------
			# Re-find the link, but don't yank it. This places the 
			# cursor on the first character of the match. The next
			# line follows the link to the page and the final line 
			# places the cursor at the bottom of the annotation 
			# page.
			# -----------------------------------------------------------------
			execute "normal! " .. '0/' .. g:interview_label_regex .. '\:\s\{1}\d\{4}' .. "\<CR>"
			execute "normal \<Plug>VimwikiVSplitLink"
			if g:new_vsplit_behaviour 
				execute "normal! \<C-w>x\<C-W>l:vertical resize " .. g:annotation_window_width .. "\<CR>"
			else
				execute "normal! \<C-W>x\<C-W>l:vertical resize " .. g:annotation_window_width .. "\<CR>"
			endif
			execute "normal! Go\<ESC>V?.\<CR>jd2o\<ESC>"
			g:current_time = strftime("%Y-%m-%d %H\:%M")
		        execute "normal! i[" .. g:current_time .. "] " .. g:list_of_tags_on_line .. "// \:" .. g:coder_initials .. "\:  \<ESC>"
			startinsert
		else
			echo "Something is not right here."		
		endif
	else
		echo "No match found on this line"
		cursor(g:current_line, 0)
	endif
enddef

# -----------------------------------------------------------------
# This function exits an annotation window and resizes remaining windows
# -----------------------------------------------------------------
def ExitAnnotation() 
	
	ParmCheck()

	# -----------------------------------------------------------------
	# Remove blank lines from the bottom of the annotation, and copy the
	# remaining bottom line to test_line 
	# -----------------------------------------------------------------
	execute "normal! Go\<ESC>V?.\<CR>jdVy\<ESC>"
	g:test_line = @@
	# -----------------------------------------------------------------
	# Build a regex that looks for the coder tag at the beginning of the line and
	# then only white space to the carriage return character.
	# -----------------------------------------------------------------
	g:find_coder_tag_regex = '\v:' .. g:coder_initials .. ':\s*\n'
	g:is_orphaned_tag = match(g:test_line, g:find_coder_tag_regex) 
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
	execute "normal! " .. ':s/\s*$//' .. "\<CR>A \<ESC>"
enddef

# -----------------------------------------------------------------
# This function determines what kind of buffer the cursor is in (annotation or
# interview) and decides whether to call Annotation() or ExitAnnotation()
# -----------------------------------------------------------------
def AnnotationToggle() 

	ParmCheck()

	# -----------------------------------------------------------------
	# Initialize buffer type variables
	# -----------------------------------------------------------------
	g:is_interview  = 0
	g:is_annotation = 0
	g:is_summary    = 0

	g:buffer_name      = expand('%:t')
	g:where_ext_starts = strridx(g:buffer_name, g:wiki_extension)
	g:buffer_name      = g:buffer_name[0 :(g:where_ext_starts - 1)]
	# -----------------------------------------------------------------
	# Check to see if it is a Summary file. It it is nothing happens.
	# -----------------------------------------------------------------
	g:summary_search_match_loc = match(g:buffer_name, "Summary")
	if (g:summary_search_match_loc == -1)	# not found
		g:is_summary = 0		# FALSE
	else
		g:is_summary = 1		# TRUE
	endif
	# -----------------------------------------------------------------
	# Check to see if the current search result buffer is
	# an annotation file. If it is ExitAnnotation() is called.
	# -----------------------------------------------------------------
	g:pos_of_4_digit_number = match(g:buffer_name, ' \d\{4}')
	if (g:pos_of_4_digit_number == -1)      " not found
		g:is_annotation = 0		# FALSE
	else
		g:is_annotation = 1		# TRUE
		ExitAnnotation()		
	endif
	# -----------------------------------------------------------------
	# Check to see if the current search result buffer is
	# from an interview file. If it is Annotation() is called.
	# -----------------------------------------------------------------
	if (g:is_annotation == 1) || (g:is_summary == 1)
		g:is_interview = 0		# FALSE
	else
		g:is_interview = 1		# TRUE
		Annotation()
	endif
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def DeleteAnnotation() 
	
	ParmCheck()

	# ------------------------------------------------------------------
	#  Figure out which version of Vim or NeoVim we're running.
	#  Older versions have a different vsplit behavior. The first
	#  test is for Vim and the second for NeoVim. has() returns a
	#  1 for true or 0 for false.
	# ------------------------------------------------------------------
	if has('nvim') && has('patch-0-6-0')
		g:new_vsplit_behaviour = 1
	elseif has('patch-8.2.3832')
		g:new_vsplit_behaviour = 1
	else
		g:new_vsplit_behaviour = 0
	endif
	# -----------------------------------------------------------------
	#  Find the tags on the line this function is called from.
	# -----------------------------------------------------------------
	g:is_tag_on_line = 1
	g:current_line = line(".")
	execute "normal! 0"
	# -----------------------------------------------------------------
	# Search for the label - number pair on the line. searchpos() 
	# returns a list with the line and column numbers of the cursor
	# position of the first character in the match. searchpos() with
	# the arguments we supplied will move the cursor to the first
	# character of match we found. So because we started in column 1
	# if the column remains at 1 we know we didn't find a match.
	# -----------------------------------------------------------------
	g:tag_search_regex = g:interview_label_regex .. '\: \d\{4}'
	g:tag_search = searchpos(g:tag_search_regex)
	g:match_line = g:tag_search[0]
	g:match_col  = virtcol('.')
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
			confirm("No annotation link found on this line.", "OK", 1)
		elseif g:match_col == (g:label_offset + 1)
			# -----------------------------------------------------------------
			# Re-find the link, but don't yank it. This places the 
			# cursor on the first character of the match. The next
			# line follows the link to the page.
			# -----------------------------------------------------------------
			execute "normal! " .. '0/' .. g:interview_label_regex .. '\:\s\{1}\d\{4}' .. "\<CR>"
			execute "normal \<Plug>VimwikiVSplitLink"
			if g:new_vsplit_behaviour 
				execute "normal! \<C-W>x\<C-W>l:vertical resize " .. g:annotation_window_width .. "\<CR>"
			else
				execute "normal! \<C-W>x\<C-W>l:vertical resize " .. g:annotation_window_width .. "\<CR>" 
			endif
			g:candidate_delete_buffer = bufnr("%")
			execute "normal \<Plug>VimwikiDeleteFile"
			# if bufwinnr() < 0 then the buffer doesn't exist.
			if (bufwinnr(g:candidate_delete_buffer) < 0)
				execute "normal! :q\<CR>"
				execute "normal! " .. g:match_line .. "G"
				g:col_to_jump_to = g:match_col - 1
				set virtualedit=all
				# the lh at the end should probably be \|
				execute "normal! 0" .. g:col_to_jump_to .. "lh"
				set virtualedit=none
				execute "normal! xf]vf)d"
				confirm("Annotation deleted.", "Got it", 1)
			else
				execute "normal! :q\<CR>"
				confirm("Annotation retained.", "Got it", 1)
			endif
		else
			echo "Something is not right here."		
		endif
	else
		echo "No match found on this line"
		cursor(g:current_line, 0)
	endif
enddef

# -----------------------------------------------------------------
# Finds a label-line number pair in a Summary buffer and uses that to to to
# that location in an interview buffer.
# -----------------------------------------------------------------
def GoToReference() 
	
	ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Find target file name.
	# -----------------------------------------------------------------
	execute "normal! 0/" .. g:interview_label_regex .. ':\s\d\{4}' .. "\<CR>" .. 'vf:hy'
	g:target_file = @@
	g:target_file = g:target_file .. g:target_file_ext
	# -----------------------------------------------------------------
	# Find target line number "
	# -----------------------------------------------------------------
	execute "normal! `<"
	execute "normal! " .. '/\d\{4}' .. "\<CR>"
	execute "normal! viwy"
	g:target_line = @@
	# -----------------------------------------------------------------
	# Use Z mark to know how to get back
	# -----------------------------------------------------------------
	execute "normal! mZ"
	# -----------------------------------------------------------------
	# Go to target file
	# -----------------------------------------------------------------
	execute "normal :e " .. g:target_file .. "\<CR>"
	execute "normal! gg"
	# -----------------------------------------------------------------
	# Find line number and center on page
	# -----------------------------------------------------------------
	execute "normal! gg"
	search(g:target_line)
	execute "normal! zz"
enddef

# -----------------------------------------------------------------
# Returns to the place called by GoToReference().
# -----------------------------------------------------------------
def GoBackFromReference() 
	execute "normal! `Zzz"
enddef

# -----------------------------------------------------------------
# ---------------------------- REPORTS ----------------------------
# -----------------------------------------------------------------

def g:FullReport(search_term: string)
	Report(search_term, "full", "FullReport", "no meta")
enddef

def g:AnnotationsReport(search_term: string)
	Report(search_term, "annotations", "AnnotationReport", "no meta") 
enddef

def g:QuotesReport(search_term: string)
	Report(search_term,  "quotes", "QuotesReport", "no meta") 
enddef

def g:MetaReport(search_term: string)
	Report(search_term,  "meta", "MetaReport", "meta") 
enddef

def VWSReport(search_term: string)
	Report(search_term, "VWS", "VWSReport", "meta") 
enddef

# -----------------------------------------------------------------
# This function produces summary reports for all tags defined in the 
# tag glossary.
# -----------------------------------------------------------------
def g:AllSummariesFull() 

	ParmCheck()
	execute "normal! :cd %:p:h\<CR>"
	
	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	g:tags_list_length = len(g:in_both_lists)

	if g:tags_list_length > 0
		GenSummaryLists("full")
	endif
	
	if (g:tags_generated == 1) && (g:tags_list_length > 0)
		popup_menu(["No, abort", "Yes, generate summary reports"], {
			 title:    "Running this function will erase older \"Full\" versions of these reports. Do you want to continue?",
			 callback: 'AllSummariesGenReportsFull', 
			 highlight: 'Question',
			 border:     [],
			 close:      'click', 
			 padding:    [0, 1, 0, 1], })
	else
		confirm("Either tags have not been generate for this session or there are no tags to create reports for.",  "OK", 1)

	endif
	
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def g:AllSummariesGenReportsFull(id: number, result: number)
	if result == 2
		execute "normal! :delmarks Q\<CR>mQ"
		confirm("Generating these summary reports will likely take a long time.",  "OK", 1)
		for index in range(0, g:tags_list_length - 1)
			execute "normal! :e " .. g:summary_file_list[index] .. "\<CR>"
			FullReport(g:in_both_lists[index])
		endfor
		execute "normal! `Q"
		put =g:summary_link_list
		execute "normal! `Q"
	endif
enddef

# -----------------------------------------------------------------
# This function produces summary reports for all tags defined in the 
# tag glossary.
# -----------------------------------------------------------------
def g:AllSummariesQuotes() 

	ParmCheck()
	execute "normal! :cd %:p:h\<CR>"
	
	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	g:tags_list_length = len(g:in_both_lists)

	if g:tags_list_length > 0
		GenSummaryLists("quotes")
	endif
	
	if (g:tags_generated == 1) && (g:tags_list_length > 0)
		popup_menu(["No, abort", "Yes, generate summary reports"], {
			 title:    "Running this function will erase older \"Quotes\" versions of these reports. Do you want to continue?",
			 callback: 'AllSummariesGenReportsQuotes', 
			 highlight: 'Question',
			 border:     [],
			 close:      'click', 
			 padding:    [0, 1, 0, 1], })
	else
		confirm("Either tags have not been generate for this session or there are no tags to create reports for.",  "OK", 1)

	endif
	
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def g:AllSummariesGenReportsQuotes(id: number, result: number)
	if result == 2
		execute "normal! :delmarks Q\<CR>mQ"
		confirm("Generating these summary reports will likely take a long time.",  "OK", 1)
		for index in range(0, g:tags_list_length - 1)
			execute "normal! :e " g:summary_file_list[index] .. "\<CR>"
			QuotesReport(g:in_both_lists[index])
		endfor
		execute "normal! `Q"
		put =g:summary_link_list
		execute "normal! `Q"
	endif
enddef

# -----------------------------------------------------------------
# Generated list of file names from the g:in_both_lists list.
# -----------------------------------------------------------------
def GenSummaryLists(summary_type: string) 
	var file_name = "undefined"
	var link_name = "undefined"
	g:summary_file_list = []
	g:summary_link_list = []
	for tag_index in range(0, (len(g:in_both_lists) - 1))
		file_name = "Summary " .. g:in_both_lists[tag_index] .. " " .. summary_type .. " batch" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		link_name = "[Summary " .. g:in_both_lists[tag_index] .. " " .. summary_type .. " batch](Summary " .. g:in_both_lists[tag_index] .. " " .. summary_type .. " batch)"
		g:summary_file_list = g:summary_file_list + [file_name]
		g:summary_link_list = g:summary_link_list + [link_name]
	endfor
enddef

# -----------------------------------------------------------------
# This builds a formatted report for the tag specified as the search_term
# argument.
# -----------------------------------------------------------------
def g:Gather(search_term: string) 
	
	ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	g:tag_search_regex      = g:interview_label_regex .. '\: \d\{4}'
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
	g:search_term = ":" .. search_term .. ":"

	@s = "# BEGIN THEME: " .. search_term ..  "\n\n"

	while search(g:search_term, "W")
		if match(getline("."), g:tag_search_regex) > 0
			@s = @s .. getline(".") .. "\n\n"
		else
			execute "normal! ?{\<CR>V/}\<CR>y"
			@s = @s .. @@ .. "\n"
			execute "normal! `>"
		endif	
	endwhile

	@s = @s "# END THEME: " .. search_term ..  "\n\n"
	execute "normal! `R\"sp"
enddef

def g:Report(search_term: string, report_type = "full", function_name = "FullReport", meta = "no meta") 
	ParmCheck()
	
	g:tag_summary_file = g:tag_summaries_path .. search_term .. ".csv"
	# Change the pwd to that of the current wiki.
	execute "normal! :cd %:p:h\<CR>"

	# Set a mark R in the current buffer which is the buffer where your
	# report will appear.
	execute "normal! :delmarks R\<CR>"
	execute "normal! ggmR"

	# Set tag summary file path
	g:tag_summary_file      = g:tag_summaries_path .. search_term .. ".csv"

	# Call VimwikiSearchTags against the a:search_term argument.
	# Put the result in loc_list which is a list of location list
	# dictionaries that we'll process.
	if (report_type == "VWS")
		g:escaped_search_term = escape(search_term, ' \')
		execute "normal! :VimwikiSearch /" .. search_term .. "/\<CR>"
	else
		execute "normal! :VimwikiSearchTags " .. search_term .. "\<CR>"
	endif

	g:loc_list = getloclist(0)

	g:escaped_search_term = escape(search_term, ' \')
	execute "normal! :VimwikiSearch /" .. search_term .. "/\<CR>"

	# Initialize values the will be used in the for loop below. The
	# summary is going to be aggregated in the s register.
	@s                               = "\n"
	@t				 = "| No. | Interview | Blocks | Lines | Annos |\n|-------:|-------|------:|------:|------:|\n"
	@u                               = ""

	g:quote_dict =  {}
	g:anno_dict = {}

	g:last_line              = 0
	g:last_int_line 	     = 0
	g:last_int_name 	     = 0
	g:last_block_num         = 0
	g:anno_int_name          = ""
	g:last_anno_int_name     = ""
	g:current_anno_int_name  = ""
	g:block_count            = 0
	g:block_line_count       = 0
	g:cross_codes            = []
	
	# Get the number of search results.
	var search_results = len(g:loc_list)
	
	# Go through all the location list search results and build the
	# interview line and annotation dictionaries. 
	for g:ll_num in range(0, search_results - 1)
		g:current_buf_name    = bufname(g:loc_list[g:ll_num]['bufnr'])[0:-g:ext_len]
		g:ll_bufnr            = g:loc_list[g:ll_num]['bufnr']
		g:line_text           = g:loc_list[g:ll_num]['text']
		g:line_text_less_meta = RemoveMetadata(g:line_text)
		g:current_buf_type    = FindBufferType(g:current_buf_name)
		if (g:current_buf_type == "Interview")
			g:current_int_line_num = GetInterviewLineInfo(g:line_text)
			PopulateQuoteLineList()
			g:last_int_line_num  = g:current_int_line_num
			g:last_int_name      = g:current_buf_name
		elseif (g:current_buf_type == "Annotation")
			PopulateAnnoLineList(g:current_buf_type)
			g:last_anno_int_name  = g:current_anno_int_name
			g:last_anno_buf_name  = g:current_buf_name
		endif
	endfor

	g:int_keys          = sort(keys(g:quote_dict))
	g:anno_keys         = sort(keys(g:anno_dict))
	g:int_and_anno_keys = sort(g:int_keys + g:anno_keys)
	

	combined_list_len = len(g:int_and_anno_keys)

	g:unique_keys = filter(copy(g:int_and_anno_keys), 'index(g:int_and_anno_keys, v:val, v:key+1) == -1')
	
	if (report_type == "full") || (report_type == "meta") || (report_type == "VWS")
		g:interview_list = g:unique_keys
		for g:int_index in range(0, len(g:interview_list) - 1)
			ProcessInterviewTitle(g:interview_list[g:int_index])
			ProcessInterviewLines(meta, report_type, search_term)
			ProcessAnnotationLines()
		endfor
		writefile(split(@u, "\n", 1), g:tag_summary_file)
	elseif (report_type == "annotations")
		g:interview_list = g:anno_keys
		for g:int_index in range(0, len(g:interview_list) - 1)
			ProcessInterviewTitle(g:interview_list[g:int_index])
			ProcessAnnotationLines()
		endfor
	elseif (report_type == "quotes")
		g:interview_list = g:int_keys
		for g:int_index in range(0, len(g:interview_list) - 1)
			ProcessInterviewTitle(g:int_keys[g:int_index])
			ProcessInterviewLines(meta, report_type, search_term )
		endfor
		writefile([@u], g:tag_summary_file)
	endif

	@t = "| No. | Interview | Blocks | Lines | Lines/Block | Annos |\n|-------:|-------|------:|------:|------:|\n"
	g:total_blocks      = 0
	g:total_lines       = 0
	g:total_annos       = 0

	for g:int_index in range(0, len(g:unique_keys) - 1)
		CreateSummaryCountTableLine()
	endfor 
	g:total_lines_per_block = printf("%.1f", str2float(g:total_lines) / str2float(g:total_blocks))
	@t = @t .. "|-------:|-------|------:|------:|------:|------:|\n"
	@t = @t .. "| Totals: |  | " .. g:total_blocks ..  " | " .. g:total_lines .. " | " .. g:total_lines_per_block .. " | " .. g:total_annos .. " |\n"
	 
	#  Write summary line to t register for last interview
	AddReportHeader(function_name, search_term)

	# Clear old material from the buffer
	execute "normal! `RggVGd"
	
	# Paste the s register into the buffer. The s register has the quotes
	# we've been copying.
	execute "normal! \"tPgga\<ESC>"
	execute "normal! gg\"qPGo"
	execute "normal! \"sp"
	execute "normal! ggdd"
enddef

#this code is in Attributes(). Need substitute a call to this function
#instead.
# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def GetInterviewFileList() 
	var file_to_add = "undefined"
	execute "normal! :cd %:p:h\<CR>"
	# get a list of all the files and directories in the pwd. Note the
	# fourth argument that is 1 makes it return a list. The first argument
	# '.' means the current directory and the second argument '*' means
	# all.
	var file_list_all = globpath('.', '*', 0, 1)
	# build regex we'll use just to find our interview files. 
	var file_regex = g:interview_label_regex .. '.md'
	#  cull the list for just those files that are interview files. the
	#  match is at position 2 because the globpath function prefixes
	#  filenames with/ which occupies positions 0 and 1.
	g:interview_list = []
	for list_item in range(0, (len(file_list_all) - 1))
		if (match(file_list_all[list_item], file_regex) == 2) 
			# strip off the leading/
			file_to_add = file_list_all[list_item][2:]
			g:interview_list = g:interview_list + [file_to_add]
		endif
	endfor
	#return l:interview_list
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def CrawlBufferTags(interview: number, interview_name: string) 
	# This is essentially the TagLinterFunction that copies the results to
	# g:tags_list
	var start_line = 2
	var end_line   = line('$')
	var tag_being_considered = "undefined"
	# move through each line testing for tags and removing duplicate tags
	# on each line
	execute "normal 2G"
	
	g:tags_on_line = []
	for line in range(start_line, end_line)
		# search() returns 0 if match not found
		g:tag_test = search(':\a.\{-}:', '', line("."))
		if (g:tag_test != 0)
			# Copy found tag
			execute "normal! viWy"
			g:tags_on_line = g:tags_on_line + [@@]
			g:tag_test = search(':\a.\{-}:', '', line("."))
			while (g:tag_test != 0)
				execute "normal! viWy"
				tag_being_considered = @@
				g:have_tag = 0
				# loop to see if we already have this tag
				for tag_index in range(0, len(g:tags_on_line) - 1 )
					if (tag_being_considered == g:tags_on_line[tag_index])
						g:have_tag = 1
					endif
				endfor
				# if we have the tag, delete it
				if g:have_tag 
					execute "normal! gvx"
				else
					g:tags_on_line = g:tags_on_line + [@@]
				endif
				g:tag_test = search(':\a.\{-}:', '', line("."))
			endwhile
		endif
		# Add tags found on line to g:tags_list
		for tag_index in range(0, len(g:tags_on_line) - 1)
			g:tags_list = g:tags_list + [[interview_name, line, g:tags_on_line[tag_index]]]
		endfor
		# Go to start of next line
		execute "normal! j0"
		g:tags_on_line = []
	endfor	
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def CalcInterviewTagCrosstabs(tags_list: list<string>, unique_tags: list<string>, interview_list: list<string>, ext_length: number): dict<any>
	#build the data structure that will hold the interview-tag crosstabs
	g:tag_count_dict       = {}
	g:initial_tag_dict     = {}

	for index in range(0, (len(interview_list) - 1)) 
		interview_list[index] = interview_list[index][:ext_length]
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
	for index in range(0, (len(unique_tags) - 1)) 
		g:initial_tag_dict[unique_tags[index]] = [0, 0, 0, 0]
	endfor
	#For create an interview dict with a the values for each key being a
	# copy of the initial_tag_dict
	for interview in range(0, (len(interview_list) - 1))
		g:tag_count_dict[interview_list[interview]] = deepcopy(g:initial_tag_dict)
	endfor

	for index in range(0, len(g:tags_list) - 1)
		# Increment the tag count for this tag
		g:tag_count_dict[tags_list[index][0]][tags_list[index][2]][0] = g:tag_count_dict[tags_list[index][0]][tags_list[index][2]][0] + 1
		# if tags_list row number minus row number minus the
		# correspondent tag tracking number isn't 1, i.e. contiguous
		if ((tags_list[index][1] - g:tag_count_dict[tags_list[index][0]][tags_list[index][2]][2]) != 1)
			#Mark that you've entered a block 
			g:tag_count_dict[tags_list[index][0]][tags_list[index][2]][3] = 1
			#Increment the block counter for this tag
			g:tag_count_dict[tags_list[index][0]][tags_list[index][2]][1] = g:tag_count_dict[tags_list[index][0]][tags_list[index][2]][1] + 1
		else
			# Reset the block counter because you're
			# inside a block now. There is no need to
			# increment the block counter.
			g:tag_count_dict[tags_list[index][0]][tags_list[index][2]][3] = 0
		endif
		# Set the last line for this kind of tag equal to the line of the tag we've been considering in this loop.
		g:tag_count_dict[tags_list[index][0]][tags_list[index][2]][2] = tags_list[index][1]
	endfor
	return g:tag_count_dict
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def FindLargestTagAndBlockCounts(tag_cross: dict<any>, unique_tags: list<string>, interview_list: list<string>, ext_length: number): list<number>
	var largest_tag_count   = 0
	var largest_block_count = 0

	for interview_index in range(0, (len(interview_list) - 1))
		for tag_index in range(0, (len(unique_tags) - 1)) 
			if (tag_cross[interview_list[interview_index]][unique_tags[tag_index]][0] > largest_tag_count)
				largest_tag_count = tag_cross[interview_list[interview_index]][unique_tags[tag_index]][0]
			endif
			if (tag_cross[interview_list[interview_index]][unique_tags[tag_index]][1]  > largest_block_count)
				largest_block_count = tag_cross[interview_list[interview_index]][unique_tags[tag_index]][1]
			endif
		endfor
	endfor
	return [largest_tag_count, largest_block_count]
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def PrintInterviewTagSummary(tag_cross: dict<any>, interview: string, unique_tags: list<string>) 
	var total_tags     = 0
	var total_blocks   = 0
	var ave_block_size = 0

	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Interview " .. interview .. " tag summary last updated at " .. report_update_time .. "**\n\n"
	execute "normal! i|Tag|Tag Count|Block Count|Average Block Size| \n"
	execute "normal! ki\<ESC>j"
	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"

	for tag_index in range(0, (len(unique_tags) - 1))
		ave_block_size = printf("%.1f", str2float(tag_cross[interview][unique_tags[tag_index]][0]) / str2float(tag_cross[interview][unique_tags[tag_index]][1]))
		execute "normal! i|" .. unique_tags[tag_index] .. "|" .. 
					 tag_cross[interview][unique_tags[tag_index]][0]. "|" .. 
					 tag_cross[interview][unique_tags[tag_index]][1]. "|" ..
					 ave_block_size        .. "|\n"
		execute "normal! ki\<ESC>j"
		total_tags   = total_tags   + tag_cross[interview][unique_tags[tag_index]][0]
		total_blocks = total_blocks + tag_cross[interview][unique_tags[tag_index]][1]
	endfor

	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"
	var ave_total_blocks_size = printf("%.1f", str2float(total_tags) / str2float(total_blocks))
	execute "normal! i| Totals |" .. 
				 total_tags            .. "|" .. 
				 total_blocks          .. "|" ..
				 ave_total_blocks_size .. "|\n\n"
	#execute "normal! 2ki\<ESC>2j"
	execute "normal! 2ki\<ESC>2j"
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def PrintTagInterviewSummary(tag_cross: dict<any>, tag_: string, interview_list: list<string>) 
	var total_tags   = 0
	var total_blocks = 0
	var ave_block_size = 1.0

	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Tag " tag_ .. " tag summary last updated at " .. report_update_time .. "**\n\n"
	execute "normal! i|Interview|Tag Count|Block Count|Average Block Size| \n"
	execute "normal! ki\<ESC>j"
	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"

	for interview_index in range(0, (len(interview_list) - 1))
		ave_block_size = printf("%.1f", str2float(tag_cross[interview_list[interview_index]][tag_][0]) / str2float(tag_cross[interview_list[interview_index]][tag_][1]))
		execute "normal! i|" interview_list[interview_index] .. "|" .. 
					\ tag_cross[interview_list[interview_index]][tag_][0] "|" .. 
					\ tag_cross[interview_list[interview_index]][tag_][1] "|" ..
					\ ave_block_size         "|\n"
		execute "normal! ki\<ESC>j"
		total_tags   = total_tags   + tag_cross[interview_list[interview_index]][tag_][0]
		total_blocks = total_blocks + tag_cross[interview_list[interview_index]][tag_][1]
	endfor

	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"
	var ave_total_blocks_size = printf("%.1f", str2float(total_tags) / str2float(total_blocks))
	execute "normal! i| Totals |" 
				\ total_tags             "|" .. 
				\ total_blocks           "|" ..
				\ ave_total_blocks_size  "|\n\n"
	#execute "normal! 2ki\<ESC>2j"
	execute "normal! 2ki\<ESC>2j"
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def GraphInterviewTagSummary(tag_cross: dict<any>, interview: string, unique_tags: list<string>, longest_tag_length: number, bar_scale: float) 
	var bar_scale_print = printf("%.1f", bar_scale)
	var offset          = 0
	var block_amount    = 0
	var tag_amount      = 0

	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Graph: Interview " interview .. "** (Updated: " .. report_update_time .. ")\n"

	for tag_index in range(0, (len(unique_tags) - 1))
		offset       = longest_tag_length - len(unique_tags[tag_index])
		block_amount = tag_cross[interview][unique_tags[tag_index]][1]
		tag_amount   = tag_cross[interview][unique_tags[tag_index]][0] - block_amount
		if tag_cross[interview][unique_tags[tag_index]][0] != 0
			execute "normal! i" unique_tags[tag_index] .. " " .. repeat(" ", offset) ..
						\	"|" repeat('□', str2nr(string(round(block_amount * bar_scale)))) .. 
						\	repeat('▤', str2nr(string(round(tag_amount * bar_scale)))) 
						\ 	" " tag_cross[interview][unique_tags[tag_index]][0] .. 
						\	"(" tag_cross[interview][unique_tags[tag_index]][1] .. ")\n"
		else
			execute "normal! i" unique_tags[tag_index] .. " " .. repeat(" ", offset) ..
						\	"|\n"
		endif
	endfor
	execute "normal! iLegend: □ = coding block bar over top of tag bar. ▤ = tag bar.\n"
	execute "normal! iScale: " bar_scale_print .. " square characters represent 1 observation.\n\n"
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def GraphTagInterviewSummary(tag_cross: dict<any>, tag_: string, interviews: list<string>, longest_tag_length: number, bar_scale: float) 
	var bar_scale_print = printf("%.1f", bar_scale)
	var offset          = 0
	var block_amount    = 0
	var tag_amount      = 0

	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Graph: Tag " tag .. "** (Updated: " .. report_update_time .. ")\n"

	for interview_index in range(0, (len(interviews) - 1))
		offset       = longest_tag_length - len(interviews[interview_index])
		block_amount = tag_cross[interviews[interview_index]][tag_][1]
		tag_amount   = tag_cross[interviews[interview_index]][tag_][0] - block_amount
		if tag_cross[interviews[interview_index]][tag_][0] != 0
			execute "normal! i" interviews[interview_index] .. " " .. repeat(" ", offset) ..
						\	"|" repeat('□', str2nr(string(round(block_amount * bar_scale)))) .. 
						\	repeat('▤', str2nr(string(round(tag_amount * bar_scale)))) 
						\ 	" " tag_cross[interviews[interview_index]][tag_][0] .. 
						\	"(" tag_cross[interviews[interview_index]][tag_][1] .. ")\n"
		else
			execute "normal! i" interviews[interview_index] .. " " .. repeat(" ", offset) ..
						\	"|\n"
		endif
	endfor
	execute "normal! iLegend: □ = coding block bar over top of tag bar. ▤ = tag bar.\n"
	execute "normal! iScale: " bar_scale_print .. " square characters represent 1 observation.\n\n"
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def CreateUniqueTagList(tags_desc: list<string>): list<string>
	var unique_tags = []
	for index in range(0, len(tags_desc) - 1)
		if (index(unique_tags, tags_desc[index][2]) == -1)
			unique_tags = unique_tags + [tags_desc[index][2]]
		endif
	endfor
	return unique_tags
enddef 

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def FindLengthOfLongestTag(tag_list: list<string>): number 
	var longest_tag_length = 0
	var test_length        = 0
	for index in range(0, len(tag_list) - 1)
		test_length = len(tag_list[index])
		if test_length > longest_tag_length
			longest_tag_length = test_length
		endif
	endfor
	return longest_tag_length
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def g:TagStats() 

	ParmCheck()
	
	var ext_length = (len(g:vimwiki_wikilocal_vars[g:wiki_number]['ext']) + 1) * -1

	# save buffer number of current file to register 'a' so you can return here
	@a = bufnr('%')
	
	g:interview_list = []
	GetInterviewFileList()

	g:tags_list = []
	
	# Go through each interview file building up a list of tags
	for interview in range(0, (len(g:interview_list) - 1))
		# go to interview file
		execute "normal :e " .. g:interview_list[interview] .. "\<CR>"
		g:interview_to_crawl = expand('%:t:r')
		CrawlBufferTags(interview, g:interview_to_crawl)	
	endfor

	g:unique_tags = sort(CreateUniqueTagList(g:tags_list))

	g:tag_cross   = CalcInterviewTagCrosstabs(g:tags_list, g:unique_tags, g:interview_list, ext_length)
	
	# Find the longest tag in terms of the number of characters in the tag.
	var len_longest_tag = FindLengthOfLongestTag(g:unique_tags)

	var window_width = winwidth('%')

	# Find the largest tag and block tallies. This will be used in the scale calculation for graphs.
	# Multiplying by 1.0 is done to coerce integers to floats.
	var largest_tag_and_block_counts = FindLargestTagAndBlockCounts(g:tag_cross, g:unique_tags, g:interview_list, ext_length)
	var largest_tag_count            = largest_tag_and_block_counts[0] * 1.0
	var largest_block_count          = largest_tag_and_block_counts[1] * 1.0

	# find the number of digits in the following counts. Used for
	# calculating the graph scale. The nested functions are mostly to
	# convert the float to an lint. Vimscript doesn't have a direct way to do this.
	var largest_tag_count_digits    = str2nr(string(trunc(log10(largest_tag_count) + 1)))
	var largest_block_count_digits  = str2nr(string(trunc(log10(largest_block_count) + 1)))

	var max_bar_width = window_width - len_longest_tag - largest_tag_count - largest_tag_count_digits - largest_block_count_digits - 8
	var bar_scale     = max_bar_width / largest_tag_count

	# Return to the buffer where these charts and graphs are going to be
	# produced and clear out the buffer.
	execute "normal! :b\<C-R>a\<CR>gg"
	execute "normal! ggVGd"

	# Print interview tag summary tables
	for interview in range(0, (len(g:interview_list) - 1))
		PrintInterviewTagSummary(g:tag_cross, g:interview_list[interview], g:unique_tags)	
	endfor
	#Print tag interview summary tables
	for tag_index in range(0, (len(g:unique_tags) - 1))
		PrintTagInterviewSummary(g:tag_cross, g:unique_tags[tag_index], g:interview_list)
	endfor
	# Print interview tag summary graphs
	for interview in range(0, (len(g:interview_list) - 1))
		GraphInterviewTagSummary(g:tag_cross, g:interview_list[interview], g:unique_tags, len_longest_tag, bar_scale)	
	endfor
	# Print interview tag summary graphs
	for tag_index in range(0, (len(g:unique_tags) - 1))
		GraphTagInterviewSummary(g:tag_cross, g:unique_tags[tag_index], g:interview_list, len_longest_tag, bar_scale)	
	endfor
	
	#execute "normal! iLongest tag " l:len_longest_tag .. "\n"
	#execute "normal! iMax bar width " l:max_bar_width .. "\n"
	#execute "normal! ilargest_tag_count " l:largest_tag_count .. "\n"
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def PopulateQuoteLineList() 
	g:current_line_dict   = {}
	g:current_line_dict = { "int_name"    : g:current_buf_name,
				"bufnr"       : g:ll_bufnr,
				"text_w_meta" : g:line_text,
				"text"        : g:line_text_less_meta,
				"line_num"    : g:current_int_line_num}
	
	if len(g:quote_dict) == 0

		g:quote_dict[g:current_buf_name] = [[ g:current_line_dict ]]
	elseif (g:current_buf_name == g:last_int_name)
		if g:current_int_line_num - g:last_int_line_num == 1 
			g:quote_dict[g:current_buf_name][g:block_count] = g:quote_dict[g:current_buf_name][g:block_count] + [ g:current_line_dict ]
		else
			g:quote_dict[g:current_buf_name]                = g:quote_dict[g:current_buf_name] + [[ g:current_line_dict ]]
			g:block_count = g:block_count + 1 
		endif
	elseif (g:current_buf_name != g:last_int_name)
		g:block_count = 0
		g:quote_dict[g:current_buf_name] = [[ g:current_line_dict ]]
	endif
enddef

def BuildListOfCrossCodes(text_w_meta: string) 
	var tag_test = matchstrpos(text_w_meta, ':\a.\{-}:', 0)
	while (tag_test[1] != -1)
		if (index(g:cross_codes, tag_test[0]) == -1)
			g:cross_codes = g:cross_codes + [ tag_test[0] ]
		endif
		tag_test = matchstrpos(text_w_meta, ':\a.\{-}:', tag_test[2])
	endwhile
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def ProcessInterviewLines(meta: string, report_type: string, search_term: string) 

	var csv_line          = "undefined"
	var lines             = 0
	var last_line_number  = "undefined"
	var first_line_number = "undefined"
	var line_type         = "undefined"
	var blocks            = 0

	if has_key(g:quote_dict, g:interview_list[g:int_index])
		if report_type != "VWS"
			@s = @s .. "**TAGGED LINES:**\n\n"
		else
			@s = @s .. "**MATCHED LINES:**\n\n"
		endif
		if meta == "meta"
			line_type = "text_w_meta"
		else
			line_type = "text"
		endif
		blocks = len(g:quote_dict[g:interview_list[g:int_index]])
		for block_index in range(0, blocks - 1)
			g:csv_block = ""
			first_line_num = printf("%04d", g:quote_dict[g:interview_list[g:int_index]][block_index][0]["line_num"])
			last_line_num  = printf("%04d", g:quote_dict[g:interview_list[g:int_index]][block_index][-1]["line_num"])
			lines = len(g:quote_dict[g:interview_list[g:int_index]][block_index])
			g:block = ""
			g:cross_codes = []
			for line_index in range(0, lines - 1)
				if (meta == "meta")
					g:block = g:block .. g:quote_dict[g:interview_list[g:int_index]][block_index][line_index]["text_w_meta"] .. "\n"
				else
					g:block = g:block .. g:quote_dict[g:interview_list[g:int_index]][block_index][line_index]["text"]
					BuildListOfCrossCodes(g:quote_dict[g:interview_list[g:int_index]][block_index][line_index]["text_w_meta"])
				endif
				csv_line = CreateCSVRecord(search_term, block_index, line_index)
				g:csv_block = g:csv_block .. csv_line .. "\n"
			endfor
			if (meta != "meta")
				g:block = substitute(g:block, '\s\+', ' ', "g")
				g:block = substitute(g:block, '(\d:\d\d:\d\d)\sspk_\d:\s', '', "g") 
				g:cross_codes_string = string(g:cross_codes)
				g:cross_codes_string = substitute(g:cross_codes_string, "\'", ' ', "g")
				g:cross_codes_string = substitute(g:cross_codes_string, ',', '', "g")
				g:cross_codes_string = substitute(g:cross_codes_string, '\s\+', ' ', "g")

				g:block = g:block .. " **" .. g:interview_list[g:int_index] .. ": " .. first_line_num .. " - " .. last_line_num .. "** " .. g:cross_codes_string .. "\n\n"
			endif

			@s = @s .. g:block
			@u = @u .. g:csv_block

			if (meta == "meta")
				@s = @s .. "\n"
			endif
		endfor
	endif
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def ProcessInterviewTitle(interview: string) 
	g:attribute_line = GetAttributeLine(interview)

	g:interview_title = "\n# ======================================\n# INTERVIEW: "
					.. interview.
					#\n# ======================================\n**ATTRIBUTES:** "
					.. g:attribute_line .. "\n"

	@s = @s .. g:interview_title
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def GetInterviewLineInfo(line_text: string): number 
	var interview_label_position      = match(line_text, g:tag_search_regex)
	var interview_line_num_pos        = match(line_text, ' \d\{4}', interview_label_position)
	var current_interview_line_number = str2nr(line_text[(interview_line_num_pos + 1):(interview_line_num_pos + 4)])
	return current_interview_line_number
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def CreateSummaryCountTableLine() 
	
	var number_of_blocks = 0
	var number_of_lines  = 0
	if has_key(g:quote_dict, g:unique_keys[g:int_index])
		number_of_blocks = len(g:quote_dict[g:unique_keys[g:int_index]])
		for block_index in range(0, number_of_blocks - 1)
			number_of_lines = number_of_lines + len(g:quote_dict[g:unique_keys[g:int_index]][block_index])
		endfor
	endif 

	var lines_per_block = str2float(number_of_lines) / str2float(number_of_blocks)
	lines_per_block = printf("%.1f", lines_per_block)

	var number_of_annos = 0
	if has_key(g:anno_dict, g:unique_keys[g:int_index])
		number_of_annos = len(g:anno_dict[g:unique_keys[g:int_index]])
	endif 

	g:total_blocks = g:total_blocks + number_of_blocks
	g:total_lines  = g:total_lines  + number_of_lines
	g:total_annos  = g:total_annos  + number_of_annos

	var interview_number = g:int_index + 1
	@t = @t ..  "| " .. l:interview_number ..  "| [" .. g:unique_keys[g:int_index] .. "](" ..
				 g:unique_keys[g:int_index] .. ") | " ..
				 number_of_blocks ..  " | " ..
				 number_of_lines .. " | " .. 
				 lines_per_block .. " | " .. 
				 number_of_annos .. " |\n"

enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def ProcessAnnotationLines() 
	var annos    = 0
	var anno_num = 0
	if has_key(g:anno_dict, g:interview_list[g:int_index])
		annos = len(g:anno_dict[g:interview_list[g:int_index]])
		g:int_annos = ""
		for anno_index in range(0, annos - 1)
			anno_num = anno_index + 1
			g:int_annos = g:int_annos .. "**ANNOTATION " .. 
						 anno_num ..  ":**\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n" ..
						 g:anno_dict[g:interview_list[g:int_index]][anno_index]["text"] ..
						 ">>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n"
		endfor
		@s = @s .. g:int_annos
	endif
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def PopulateAnnoLineList(buf_type: string) 
	g:current_anno_dict           = {}
	g:current_anno_int_name       = GetAnnoInterview(g:current_buf_name)
	g:anno_text                   = GetAnnoText(g:ll_bufnr)
	g:current_anno_dict = { "int_name"    : g:current_anno_int_name,
				   "anno_name"   : g:current_buf_name,
				   "bufnr"       : g:ll_bufnr,
				   "text"        : g:anno_text }
	
	if len(g:anno_dict) == 0
		g:anno_dict[g:current_anno_dict.int_name] = [ g:current_anno_dict ]
	elseif (g:current_anno_dict.int_name == g:last_anno_int_name)
		if (g:current_buf_name != g:last_anno_buf_name)
			g:anno_dict[g:current_anno_dict.int_name] = g:anno_dict[g:current_anno_dict.int_name] + [ g:current_anno_dict ]
		endif
	elseif (g:current_anno_dict.int_name != g:last_anno_int_name)
		g:anno_dict[g:current_anno_dict.int_name] = [ g:current_anno_dict ]
	endif
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def GetAnnoInterview(buffer_name: string): string
	var line_num_loc  = match(buffer_name, ':')
	var cropped_name  = buffer_name[0:line_num_loc - 1]
	return cropped_name
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def GetAnnoText(bufnr: number): string 
	# Go to the Location List result under the cursor.
	execute "normal! :buffer " .. bufnr .. "\<CR>"
	# Copy the annotation text.
	execute "normal! G$?.\<CR>Vggy"
	return @@
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def CreateCSVRecord(search_term: string, block_index: number, line_index: number): string
	# -----------------------------------------------------------------
	# Build output record
	# -----------------------------------------------------------------
	var attributes = substitute(g:attribute_line, '\s\+', '', "g")
	attributes = substitute(attributes , ":", ",", "g")
	attributes = attributes[:-3]
	var block = block_index + 1
	var outline =           search_term .. "," ..
				 g:interview_list[g:int_index]. "," ..
				 block .. "," ..
				 g:quote_dict[g:interview_list[g:int_index]][block_index][line_index]["line_num"]. "," ..
				 "\"" .. g:quote_dict[g:interview_list[g:int_index]][block_index][line_index]["text"] .. "\"," ..
				 g:current_buf_length.
				 attributes 

	return outline
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def FindBufferType(current_buf_name: string): string
	if match(current_buf_name, "Summary") != -1
		return "Summary"
	elseif match(current_buf_name, ': \d\{4}') != -1
		return  "Annotation"
	elseif match(current_buf_name, g:interview_label_regex) != -1
		return "Interview"
	else
		return "Other"
	endif
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def RemoveMetadata(line_text: string): string
	# -----------------------------------------------------------------
	#  There is something strange going on here. You shouldn't
	#  have to go back 6 columns from the match. If you don't you
	#  get <e2><94> characters at the end of the line. I can't
	#  figure out what these are but if you chop them off the
	#  function works.
	# -----------------------------------------------------------------
	g:border_location = match(line_text, g:tag_search_regex) - 6
	return line_text[:g:border_location]
enddef



# ------------------------------------------------------
#
# ------------------------------------------------------
def AddReportHeader(report_type: string, search_term: string) 
	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	var report_header = "\n# *********************************************************************************\n"
	report_header = report_header .. "# *********************************************************************************\n"
	report_header = report_header .. "  **" .. report_type .. "(\"" .. search_term .. "\")**\n  Created by **" .. g:coder_initials .. "**\n  on **" .. report_update_time .. "**"
	report_header = report_header .. "\n# *********************************************************************************"
	report_header = report_header .. "\n# *********************************************************************************"
	@q = report_header .. "\n\n**SUMMARY TABLE:**\n\n" 
enddef


# ------------------------------------------------------
#
# ------------------------------------------------------
def GetAttributeLine(interview: string): number 
	# -----------------------------------------------------------------
	# Go to the Location List result under the cursor.
	# -----------------------------------------------------------------
	execute "normal! :e " .. interview .. "\.md\<CR>"
	# -----------------------------------------------------------------
	# Get the first line and the length of the buffer in lines.
	# -----------------------------------------------------------------
	execute "normal! ggVy"
	g:attribute_row = @@
	g:current_buf_length = line('$')
	execute "normal! \<C-o>"
	return g:attribute_row
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def TrimLeadingPartialSentence() 
	#execute "normal! vip\"by"
	#execute "normal! `<v)hx"
	execute "normal! 0v)hx"
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def TrimTrailingPartialSentence() 
	execute "normal! $"
	g:trim_tail_regex = '**'. g:tag_search_regex
	g:tag_test = search(g:trim_tail_regex, 'b', line("."))
	execute "normal! hv(d0"
	#execute "normal! $" '?**' .. g:tag_search_regex .. "\<CR>hv(d"
	#execute "normal! vip\"by"
	#execute "normal! `>(v)di\r\r\<ESC>kk"
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def TrimLeadingAndTrailingPartialSentence() 
	TrimLeadingPartialSentence()
	TrimTrailingPartialSentence()
enddef


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
def g:TagsLoadedCheck()
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
def GetTagUpdate() 

	ParmCheck()

	confirm("Populating tags. This may take a while.", "Got it", 1)
	echo "GetTagUpdate enter"
	CreateTagDict()

	execute "normal! :delmarks Y\<CR>"
	execute "normal! mY"
	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# ------------------------------------------------------
	# Find the vimwiki that the current buffer is in.
	# ------------------------------------------------------
	# g:wiki_number = vimwiki#vars#get_bufferlocal('wiki_nr') 
	# -----------------------------------------------------------------
	# Save the current buffer so any new tags are found by
	# VimwikiRebuildTags
	# -----------------------------------------------------------------
	execute "normal :w\<CR>"
	GenTagsWithLocationList()
	# -----------------------------------------------------------------
	# g:current_tags is used in vimwiki's omnicomplete function. At this
	# point this is a modifcation to ftplugin#vimwikimwiki#Complete_wikifiles
	# where
	#    tags = vimwiki#tags#get_tags()
	# has been replaced by
	#    tags = deepcopy(g:current_tags)
	# This was done because as the number of tags grows in a project
	# vimwiki#tags#get_tags() slows down.
	# -----------------------------------------------------------------
	g:current_tags = sort(g:current_tags, 'i')
	# ------------------------------------------------------
	# Set the current wiki as the wiki that g:current_tags were last
	# generated for. Also mark that a set of current tags has been
	# generated to true.
	# ------------------------------------------------------
	g:last_wiki_tags_generated_for = g:wiki_number
	g:current_tags_set_this_session = 1
	# ------------------------------------------------------
	# Popup menu to display the list of current tags sorted in
	# case-insenstive alphabetical order
	# ------------------------------------------------------
	GenDictTagList()
	UpdateCurrentTagsList()
	confirm("In GetTagUpdate",  "OK", 1)
	UpdateCurrentTagsPage()
	CurrentTagsPopUpMenu()

	g:current_tags = sort(g:just_in_dict_list + g:just_in_current_tag_list + g:in_both_lists)

	# ------------------------------------------------------
	# Add an element to the current wiki's configuration dictionary that
	# marks it as having had its tags generated in this vim session.
	# ------------------------------------------------------
	g:vimwiki_wikilocal_vars[g:wiki_number]['tags_generated_this_session'] = 1
	execute "normal! `Yzz"
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def GenTagsWithLocationList() 
	ParmCheck()
	# Change the pwd to that of the current wiki.
	confirm("Entered GenTagsWithLocationList",  "OK", 1)
	execute "normal! :cd %:p:h\<CR>"
	# Call VimwikiSearchTags against the a:search_term argument.
	# Put the result in loc_list which is a list of location list
	# dictionaries that we'll process.
	silent execute "normal! :VimwikiSearch /" '\(^\|\s\)\zs:\([^:''[:space:]]\+:\)\+\ze\(\s\|$\)' .. "/g\<CR>"

	g:loc_list = getloclist(0)
	var tag_list = []

	var search_results = len(g:loc_list)

	var first_col = g:loc_list[0]['col'] 
	var last_col  = g:loc_list[0]['end_col'] - 3
	var test_tag  = g:loc_list[0]['text'][first_col:last_col]

	if g:loc_list[0]['lnum'] > 1
		tag_list = tag_list + [ test_tag ]
	endif

	for line_index in range(1, search_results - 1)
		first_col = g:loc_list[line_index]['col'] 
		last_col  = g:loc_list[line_index]['end_col'] - 3
		test_tag = g:loc_list[line_index]['text'][first_col:last_col]
		if (index(tag_list, test_tag) == -1)
			tag_list = tag_list + [ test_tag ]
		endif
	endfor	
	g:current_tags = deepcopy(tag_list)
	confirm("Finished GenTagsWithLocationList",  "OK", 1)
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def UpdateCurrentTagsPage() 
	# -----------------------------------------------------------------
	# Use R mark to know how to get back
	# -----------------------------------------------------------------
	execute "normal! :delmarks R\<CR>"
	execute "normal! mR"
	# Open the Tag List Current Page
	execute "normal! :e " .. g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. "Tag List Current" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
	# Delete what is there
	execute "normal! ggVGd"
	var tag_update_time = strftime("%Y-%m-%d %a %H:%M:%S")
	execute "normal! i**Tag list last updated at: " .. tag_update_time .. "**\n\<CR>"
	execute "normal! i- **There are " .. len(g:in_both_lists) .. " tag(s) defined in the Tag Glossary and included in the current tags list.**\n"
	put =g:in_both_lists
	execute "normal! Go"
	execute "normal! i\n- **There are " .. len(g:just_in_current_tag_list) .. " tag(s) included in the current tags list, but not defined in the Tag Glossary.**\n"
	put =g:just_in_current_tag_list
	execute "normal! Go"
	execute "normal! i\n- **There are " .. len(g:just_in_dict_list) .. " tag(s) defined in the Tag Glossary but not used in coding.**\n"
	put =g:just_in_dict_list
	execute "normal! ggj"
	# Return to where you were
	execute "normal! `Rzz"
	
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def g:UpdateCurrentTagsList() 
	var is_in_list = 0
	var print_list_item = "undefined"
	g:tag_dict_keys 		= keys(g:tag_dict)
	g:tag_dict_keys 		= sort(g:tag_dict_keys, 'i')
	
	g:tag_list_output               = []
	g:in_both_lists  		= []
	g:just_in_dict_list		= []
	g:just_in_current_tag_list	= []

	for tag_dict_tag in range(0, (len(g:tag_dict_keys) - 1))
		is_in_list = index(g:current_tags, g:tag_dict_keys[tag_dict_tag])
		if is_in_list >= 0
			print_list_item = g:tag_dict_keys[tag_dict_tag]
			g:in_both_lists = g:in_both_lists + [ print_list_item ]
		elseif is_in_list < 0
			print_list_item = g:tag_dict_keys[tag_dict_tag]
			g:just_in_dict_list = g:just_in_dict_list + [ print_list_item ]
		endif
	endfor

	for current_tag in range(0, (len(g:current_tags) - 1))
		is_in_list = index(g:tag_dict_keys, g:current_tags[current_tag])
		if is_in_list < 0
			print_list_item = g:current_tags[current_tag]
			g:just_in_current_tag_list = g:just_in_current_tag_list + [ print_list_item ]
		endif
	endfor

	g:tag_list_output = ["DEFINED:", " "] + g:in_both_lists + [" ", "UNDEFINED:", " "] + g:just_in_current_tag_list + [" ", "DEFINED BUT NOT USED:", " "] + g:just_in_dict_list 
	#g:tag_list_output = sort(g:tag_list_output)
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def g:TagsGenThisSession() 
	
	ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# ------------------------------------------------------
	# See if the wiki config dictionary has had a
	# tags_generated_this_session key added.
	# ------------------------------------------------------
	g:tags_gen_this_wiki_this_session = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
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
def g:ToggleDoubleColonOmniComplete() 
	if maparg("::", "i") == ""
		inoremap :: <ESC>a:<ESC>:call TagsGenThisSession()<CR>
		confirm("Double colon (::) omni-completion on.", "Got it", 1)
	else
		iunmap ::
		confirm("Double colon (::) omni-completion off.", "Got it", 1)
	endif
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def GenDictTagList() 
	g:dict_tags = []
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

	confirm("Entered CreatTagDict", "Got it", 1)
	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	confirm("Entered CreateTagDict",  "OK", 1)
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Use Y mark to know how to get back
	# -----------------------------------------------------------------
	execute "normal! mY"
	# -----------------------------------------------------------------
	# Go to the tag glossary
	# -----------------------------------------------------------------
	execute "normal! :e .. g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. Tag Glossary" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
	execute "normal! gg"
	# -----------------------------------------------------------------
	# Define an empty tag dictionary
	# -----------------------------------------------------------------
	g:tag_dict = {}
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
	confirm("Finished CreateTagDict",  "OK", 1)
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
	var popup_message = "undefined"
	if (tag_message == 1)
		popup_message = "Press <F2> to populate the current tag list."
	elseif (tag_message == 2)
		popup_message = "A tag list for this wiki has not been generated yet this session. Press <F2> to populate the current tag list with this wiki\'s tags."
	else 
		popup_message = "Update the tag list with this wiki\'s tags by pressing <F2>."
	endif
	confirm(popup_message, "Got it", 1)
enddef


# ------------------------------------------------------------
# Find the last tag entered on the page. Do this by putting
# :changes into register c and then searching it for the
# first tag. 
# ------------------------------------------------------------
def FindLastTagAddedToBuffer() 
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
	g:changes = substitute(g:changes, '\n', '', "g")

	g:most_recent_tag_in_changes       = ""
	g:is_tag_on_page                   = 0
	g:most_recent_tag_in_changes_start = match(g:changes, ':\a\w\{1,}:\(.*:\a\w\{1,}:\)\@!')
	# ------------------------------------------------------------
	# If there is a tag on the page, find what it is.
	# ------------------------------------------------------------
	if g:most_recent_tag_in_changes_start != -1
		g:most_recent_tag_in_changes_end = match(g:changes, ':', g:most_recent_tag_in_changes_start + 1)
		g:most_recent_tag_in_changes = g:changes[(g:most_recent_tag_in_changes_start + 1):(g:most_recent_tag_in_changes_end - 1)]
		g:is_tag_on_page = 1
	endif
	# ------------------------------------------------------------
	# Next we have to take g:most_recent_tag_in_changes and make it the
	# first tag in matched_tag_list. We'll also have to make sure
	# that it doesn't appear in matched tag list twice.
	# ------------------------------------------------------------
	if g:is_tag_on_page == 1
		g:matched_tag_list = [g:most_recent_tag_in_changes] 
	endif
enddef

def FillChosenTag(id: number, result: number) 
	# ------------------------------------------------------------
	# When ESC is press the a:result value will be -1. So take no action.
	# ------------------------------------------------------------
	if (result > 0)
		# ------------------------------------------------------------
		# Now we have our choice which corresponds to the matched-tag-
		# list element. All that remains is to fill the tag.
		# ------------------------------------------------------------
		g:tag_to_fill = ":" .. g:matched_tag_list[result - 1] .. ":"
		# ------------------------------------------------------------
		# Now we have to find the range to fill
		# ------------------------------------------------------------
		cursor(g:bottom_line, g:bottom_col)
		g:line_of_tag_to_fill = search(g:tag_to_fill, 'bW')
		# ------------------------------------------------------------
		# If the tag_to_fill is found above the cursor position, and
		# its not more than 20 lines above the contiguously tagged
		# block above the cursor position.
		# ------------------------------------------------------------
		g:proceed_to_fill = 0
		if (g:tag_fill_option == "bottom of contiguous block")
			g:lines_to_fill = g:bottom_line - g:line_of_tag_to_fill
			g:proceed_to_fill = 1
		elseif (g:line_of_tag_to_fill != 0)
			#execute "normal! ?" g:tag_to_fill .. "\<CR>"
			g:lines_to_fill = g:bottom_line - g:line_of_tag_to_fill
			g:proceed_to_fill = 1
		endif
		# ------------------------------------------------------------
		# This actually fills the tag.
		# ------------------------------------------------------------
		cursor(g:bottom_line, g:bottom_col)
		if (g:proceed_to_fill)
			execute "normal! V" .. g:lines_to_fill .. "k\<CR>:s/$/ " .. g:tag_to_fill .. "/\<CR>A \<ESC>"
		else
			confirm("Tag not found above the cursor. No action taken.",  "OK", 1)
		endif
	endif
enddef
	
def TagFillWithChoice() 
	# ---------------------------------------------
	# Set tag fill mode
	# ---------------------------------------------
	if !exists("g:tag_fill_option") 
		g:tag_fill_option = "last tag added"
	endif
	if (g:tag_fill_option == "last tag added")
		FindLastTagAddedToBuffer()
	endif
	# ----------------------------------------------------
	# Mark the line and column number where you want the bottom of the tag block to be.
	# -----------------------------------------------------
	g:bottom_line = line('.')
	g:bottom_col = virtcol('.')
	
	g:block_tags_list = []
	g:tag_block_dict  = {}

	CreateBlockMetadataDict()

	cursor(g:bottom_line, g:bottom_col)
	# ------------------------------------------------------------
	#  If the list has more than one element you want the user to 
	#  choose the proper tag. Hitting enter chooses the first item in the list.
	# ------------------------------------------------------------
	if (len(g:block_tags_list) >= 1)
		popup_menu(g:block_tags_list, {
			 title:    "Choose tag (Mode = " .. g:tag_fill_option .. "; F4 to change mode)",
			 callback: 'BuildMetadataBlockFill', 
			 highlight: 'Question',
			 border:     [],
			 close:      'click', 
			 padding:    [0, 1, 0, 1],
			 })
	else	
		confirm("Tag not found above the cursor",  "OK", 1)
	endif

	cursor(g:bottom_line, g:bottom_col)
	execute "normal! zzA "
enddef

def FillTagBlock(id: number, result: number) 
	# ------------------------------------------------------------
	# When ESC is press the a:result value will be -1. So take no action.
	# ------------------------------------------------------------
	if (result > 0)

		g:block_range_as_char = keys(g:tag_block_dict)
		g:block_range         = []

		for index in range(0, len(g:block_range_as_char) - 1)
			g:block_range = g:block_range + [ str2nr(g:block_range_as_char[index]) ]
		endfor

		g:block_range     = sort(g:block_range)
		
		g:block_range_max = g:bottom_line
		g:block_range_min = min(g:block_range)

		for index_2 in range(g:block_range_min, g:block_range_max)
			if has_key(g:tag_block_dict, index_2)
				if (index(g:tag_block_dict[index_2][0], g:tag_list_to_present[result - 1]) != -1)
					g:top_fill_line = index_2
				endif
			endif
		endfor

		for index_3 in range(g:block_range_min, g:block_range_max)
			CreateFillLine(index_3)
			cursor(index_3, g:tag_block_dict[index_3][2])
			execute "normal! i" g:meta_fill_line .. "\<CR>"
		endfor
	endif
enddef

def CreateFillLine(line: number) 
	g:meta_fill_line = ""
	var spacer = "undefined"
	for tags_index in range(0, len(g:block_tags_list) - 1)
		if has_key(g:tag_block_dict, line)
			# if this line has the block
			if (index(g:tag_block_dict[line][0], g:block_tags_list[tags_index] != -1))
				g:meta_fill_line = g:meta_fill_line .. " :" .. g:block_tags_list[tags_index] .. ":"
			elseif (line >= g:top_fill_line)
				g:meta_fill_line = g:meta_fill_line .. " :" .. g:block_tags_list[tags_index] .. ":"
			else
				spacer = repeat(" ", len(g:block_tags_list[tags_index])) + 3 
				g:meta_fill_line = g:meta_fill_line .. spacer
			endif
		endif			
	endfor
	if (has_key(g:block_tag_list) == -1) && (line >= g:top_fill_line)
		g:meta_fill_line = g:meta_fill_line .. " :" .. g:block_tags_list[tags_index] .. ":"
		#g:meta_fill_line = g:meta_fill_line .. " " .. g:tag_block_dict[line][1]
		#This may need to be fixed
	endif
enddef

def FindFirstInterviewLine()
	execute "normal! gg"
	g:tag_search_regex = g:interview_label_regex .. '\: \d\{4}'
	g:first_interview_line = search(g:tag_search_regex, "W")
	cursor(g:bottom_line, g:bottom_col)
enddef
	

def CreateBlockMetadataDict() 

	g:block_metadata             = {}
	g:tags_on_line               = []
	g:block_tags_list            = []
	g:sub_blocks_tags_lists      = []
	#g:last_match_line = g:match_line
	g:contiguous_block           = 1
	g:found_block                = 0
	g:block_switch               = 0
	g:continue_searching         = 1
	g:while_counter              = 0

	FindFirstInterviewLine()

	#if there are interview lines in the buffer
	if g:first_interview_line > 0
		# find the block range
		while (line('.') >= g:first_interview_line) && (g:continue_searching == 1) && (line('.') > 1)
			ProcessLineMetadata()
			# Searching to see if we found any tags on line('.')
			# No tags on line, and haven't found block
			if (len(g:block_metadata[line('.')][2]) == 0) && (g:found_block == 0)
				g:continue_searching = 1
			# Found tags (start of sub-block) and the found_block flag still false
			elseif (len(g:block_metadata[line('.')][2]) != 0) && (g:found_block == 0)
				g:found_block        = 1
				g:continue_searching = 1
			# Inside a sub-block
			elseif (len(g:block_metadata[line('.')][2]) != 0) && (g:found_block == 1)
				g:found_block        = 1
				g:continue_searching = 1
			# Moved past the found block
			elseif (len(g:block_metadata[line('.')][2]) == 0) && (g:found_block == 1)
				# See if you have the last tag added in the
				# block_tags_list
				if (g:tag_fill_option == "last tag added")
					if (index(g:block_tags_list, g:most_recent_tag_in_changes) != -1)
						g:continue_searching = 0
						g:found_block        = 0
					elseif (index(g:block_tags_list, g:most_recent_tag_in_changes) == -1)
						g:continue_searching = 1
						g:found_block        = 0
					endif
				else
					g:continue_searching         = 0 
				endif
			endif
			if g:continue_searching == 1
				execute "normal! k"
			else
				remove(g:block_metadata, line('.'))
			endif
		endwhile
	else
		confirm("No interview lines in this buffer",  "OK", 1)
		g:block_tags_list = []
	endif

	g:block_tags_list = sort(g:block_tags_list)
enddef

def CreateSubBlocksLists() 
	g:sub_blocks_tags_lists = []
	var found_block = 0
	for line_index in range(str2nr(g:block_lines[0]), str2nr(g:block_lines[-1]))
		if (len(g:block_metadata[line_index][2]) != 0) && (found_block == 0)
			g:sub_blocks_tags_lists = g:sub_blocks_tags_lists + [ [ g:block_metadata[line_index][2] , [ line_index ] ] ]
			found_block        = 1
		# Inside a sub-block
		elseif (len(g:block_metadata[line_index][2]) != 0) && (found_block == 1)
			# add new tages
			for tag_index in range(0, len(g:block_metadata[line_index][2]) - 1)
				if (index(g:sub_blocks_tags_lists[-1][0], g:block_metadata[line_index][2][tag_index]) == -1)
					g:sub_blocks_tags_lists[-1][0] = g:sub_blocks_tags_lists[-1][0] + [ g:block_metadata[line_index][2][tag_index] ]
				endif
			endfor
			# add line number
			g:sub_blocks_tags_lists[-1][1] = g:sub_blocks_tags_lists[-1][1] + [ line_index ]
			found_block          = 1
			g:continue_searching = 1
		# Moved past the found block
		elseif (len(g:block_metadata[line_index][2]) == 0) && (found_block == 1)
			# See if you have the last tag added in the block_tags_list
			found_block = 0
		endif
	endfor
enddef

def BuildMetadataBlockFill(id: number, result: number) 

	g:fill_tag = g:block_tags_list[result - 1]

	g:block_lines = sort(keys(g:block_metadata))

	FindUpperTagFillLine()
	AddFillTags()
	CreateSubBlocksLists()

	for line_index in range(str2nr(g:block_lines[0]), str2nr(g:block_lines[-1]))
		g:formatted_metadata = ""

		#Find sub-block and its associated tag list
		for sub_block_index in range(0, len(g:sub_blocks_tags_lists) - 1)
			if (index(g:sub_blocks_tags_lists[sub_block_index][1], line_index) != -1)
				g:sub_block_tag_list = sort(g:sub_blocks_tags_lists[sub_block_index][0])
			endif
		endfor

		for tag_index in range(0, len(g:sub_block_tag_list) - 1)
			if (index(g:block_metadata[line_index][2], g:sub_block_tag_list[tag_index]) != -1)
				g:formatted_metadata = g:formatted_metadata .. " :" .. g:sub_block_tag_list[tag_index] .. ":"
			else
				g:formatted_metadata = g:formatted_metadata repeat(' ', len(g:sub_block_tag_list[tag_index]) + 3)
			endif
		endfor

		g:block_metadata[line_index] = g:block_metadata[line_index] + [ g:formatted_metadata g:block_metadata[line_index][3] ]
		
		g:block_metadata[line_index][4] = substitute(g:block_metadata[line_index][4], '\s\+$', '', 'g')
		if g:block_metadata[line_index][4] == ""
			g:block_metadata[line_index][4] = "  "
		endif
	endfor
	WriteInFormattedTagMetadata()
enddef

def AddFillTags() 
	for line_index in range(g:upper_fill_line + 1, str2nr(g:block_lines[-1]))
		g:block_metadata[line_index][2] = g:block_metadata[line_index][2] + [ g:fill_tag ]
		g:block_metadata[line_index][2] = sort(g:block_metadata[line_index][2]) 
	endfor
enddef

def FindUpperTagFillLine() 
	for line_index in range(str2nr(g:block_lines[0]), str2nr(g:block_lines[-1]))
		if (index(g:block_metadata[line_index][2], g:fill_tag) != -1)
			g:upper_fill_line = line_index
		endif
	endfor
enddef

def WriteInFormattedTagMetadata() 
	set virtualedit=all
	for line_index in range(str2nr(g:block_lines[0]), str2nr(g:block_lines[-1]))
		cursor(line_index, 0)
		execute "normal! " .. g:block_metadata[line_index][1] .. "|lv$dh"
		execute "normal! a" .. g:block_metadata[line_index][4] .. "\<ESC>"

	endfor
	set virtualedit=none

	cursor(g:bottom_line, g:bottom_col)
	execute "normal! zzA "
enddef

def ProcessLineMetadata() 
	g:tags_on_line            = []
	g:non_tag_metadata        = ""

	set virtualedit=all
	execute "normal! 0Vygv/│\<CR>/│\<CR>\<ESC>"
	g:right_border_col     = col('.')
	g:right_border_virtcol = virtcol('.')
	set virtualedit=none
	g:block_metadata[line('.')] = [ g:right_border_col , g:right_border_virtcol ]
	
	# copy everything beyond the right of the right label pane border.
	execute "normal! lv$y"
	#execute "normal! lvg_y"
	# Tokenize what got copied into a list called g:line_meta_data
	g:line_metadata = split(@@)
	for index in range(0, len(g:line_metadata) - 1)
		if (match(g:line_metadata[index], ':\a.\{-}:') != -1)
			g:tags_on_line = g:tags_on_line + [ g:line_metadata[index][1:-2] ]
			if (index(g:block_tags_list, g:line_metadata[index][1:-2]) == -1)
				g:block_tags_list = g:block_tags_list + [ g:line_metadata[index][1:-2] ]
			endif
		else
			g:non_tag_metadata = g:non_tag_metadata .. " " .. g:line_metadata[index]
		endif
	endfor
	g:block_metadata[line('.')] = g:block_metadata[line('.')] + [ g:tags_on_line , g:non_tag_metadata ]
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def ChangeTagFillOption() 
	if (!exists("g:tag_fill_option"))
		g:tag_fill_option = "last tag added"
		confirm("Default tag presented when F5 is pressed will be the last tag added to the buffer.",  "OK", 1)
	elseif (g:tag_fill_option == "last tag added")
		g:tag_fill_option = "bottom of contiguous block"
		confirm("Default tag presented when F5 is pressed will be the last tag in the contiguous block above the cursor.",  "OK", 1)
	elseif (g:tag_fill_option == "bottom of contiguous block")
		g:tag_fill_option = "last tag added"
		confirm("Default tag presented when F5 is pressed will be the last tag added to the buffer.",  "OK", 1)
	endif
enddef


# ------------------------------------------------------
#
# ------------------------------------------------------
def SortTagDefs() 
	execute "normal! :%s/}/}\\r/g\<CR>"
	execute "normal! :g/{/,/}/s/\\n/TTT\<CR>"
	execute "normal! :3,$sort \i\<CR>"
	execute "normal!" .. ':3,$g/^$/d' .. "\<CR>"
	execute "normal! :%s/TTT/\\r/g\<CR>"
enddef


# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def GetTagDef() 
	
	ParmCheck()

	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Find the tag under the cursor. If it exists in the tag_dict display
	# the definition in a popup window, else offer to add the tag to the
	# Tag Glossary page.
	# -----------------------------------------------------------------
	g:tag_to_test = GetTagUnderCursor()
	
	var tag_check_message = g:tag_to_test .. "is not defined blah in the Tag Glossary\. Would you like to add it now?"
 	if (g:tag_to_test != "") 
		if (has_key(g:tag_dict, g:tag_to_test))
 			popup_atcursor(get(g:tag_dict, g:tag_to_test), {
 				 'border': [],
 				 'close' : 'click',
 				 })
 		else
 			popup_menu(["Yes", "No"], {
			         title: tag_check_message, 
				 callback: 'AddNewTagDef',
				 highlight: 'Question',
				 minwidth: 50,
				 maxwidth: 100, 
				 pos: "center", 
 				 border: [],
 				 close : 'click',
				 padding: [0, 1, 0, 1] })
		endif
	else
 		popup_atcursor("There is no valid tag under the cursor.", {
 			 'border': [],
 			 'close' : 'click',
 			 })
 	endif
enddef


# -----------------------------------------------------------------
# See if word under cursor is a tag. ie. a word surrounded by colons
# Test case where the cursor is on white space.
# -----------------------------------------------------------------
def GetTagUnderCursor(): string       
	execute "normal! viWy"        
	var word_under_cursor             = @@ 
	# Want tag_test to be 0
	var tag_test                      = matchstr(word_under_cursor, ':.\{-}:')
	# -----------------------------------------------------------------
	# Test to see if g:word_under_cursor is just white space. If not,
	# test to see if the word_under_cursor is surrounded by colons.
	# -----------------------------------------------------------------
	if word_under_cursor == tag_test
		return word_under_cursor[1:-2]
	else
		return ""
	endif
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def AddNewTagDef(id: number, result: number) 
	if result == 1
		# -----------------------------------------------------------------
		# Save buffer number of current file to register 'a' so you can return here
		# -----------------------------------------------------------------
		execute "normal! :delmarks Z\<CR>"
		execute "normal! mZ"
		# -----------------------------------------------------------------
		# Go to Tag Glossary and create a new tag template populated with the 
		# g:tag_to_test value
		# -----------------------------------------------------------------
		execute "normal! :e .. g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. Tag Glossary" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
		execute "normal! Go{\n## Name: " .. g:tag_to_test .. "\n**Detailed Description:** \n**Incl. Criteria:** \n**Excl. Criteria:** \n**Example:** \n}\<ESC>4kA"
		SortTagDefs()
		execute "normal! /Name: " .. g:tag_to_test .. "\<CR>jA"
		confirm("Add your tag description.\n\nWhen you are finished press <F2> to update the tag list.\n\n", "OK", 1)
	endif
enddef

# -----------------------------------------------------------------
# ---------------------------- ATTRIBUTES -------------------------
# -----------------------------------------------------------------

# ------------------------------------------------------

# ------------------------------------------------------
def Attributes(sort_col = 1) 
	
	ParmCheck()

	# from the buffer which should be the line of the interview attribute
	# tags. We're going to build our output in two reg
	g:attrib_chart = ""
	g:attrib_csv   = ""
	# from the buffer which should be the line of the interview attribute
	# tags. We're going to build our output in two reg
	g:attrib_chart = ""
	g:attrib_csv   = ""
	GetInterviewFileList()

	# save buffer number of current file to register 'a' so you can return here
	@a = bufnr('%')
	# go through the list of files copying and processing the first line
	# from the buffer which should be the line of the interview attribute
	# tags. We're going to build our output in two reg
	g:attrib_chart = ""
	g:attrib_csv   = ""
	for interview in range(0, (len(g:interview_list) - 1))
		# go to interview file
		execute "normal :e " .. g:interview_list[interview] .. "\<CR>"
		# copy first row which should be the attribute tags.
		execute "normal! ggVy"
		g:attribute_row = @@
		# format the attribute tags for the chart and for the csv
		g:interview_label = "| [[" .. g:interview_list[interview][:-4] .. "]]"
		g:attrib_chart_line = substitute(g:attribute_row, ": :", "|", "g")
		g:attrib_chart_line = substitute(g:attrib_chart_line, ":", "|", "g")
		g:attrib_chart_line = g:interview_label .. g:attrib_chart_line
		g:attrib_chart = g:attrib_chart .. g:attrib_chart_line
	endfor
	# return to page where you're going to print the chart and paste the
	# chart.
	execute "normal! :b\<C-R>a\<CR>gg"
	execute "normal! ggVGd"
	execute "normal! i" .. g:attrib_chart .. "\<CR>"
	execute "normal! Go\<ESC>v?.\<CR>jdgga\<ESC>\<CR>gg"
	ColSort(sort_col)
enddef

# ------------------------------------------------------

# ------------------------------------------------------
# ------------------------------------------------------
# Sort the Attribute table by column number
# ------------------------------------------------------
def ColSort(column: number) 
	g:sort_regex = "/\\(.\\{-}\\zs|\\)\\{" .. column .. "}/"
	execute "normal! :sort " .. g:sort_regex .. "\<CR>"
enddef

# -----------------------------------------------------------------
# ---------------------------- OTHER ------------------------------
# -----------------------------------------------------------------

# ------------------------------------------------------
#
# ------------------------------------------------------
def UpdateSubcode() 
	
	ParmCheck()

	# -----------------------------------------------------------------
	# Clear @@ register.
	# -----------------------------------------------------------------
	@@ = ""
	# -----------------------------------------------------------------
	# Process the first case.  Initialise list
	# -----------------------------------------------------------------
	g:subcode_list = []
	# -----------------------------------------------------------------
	# VWS to get search results and open location list
	# -----------------------------------------------------------------
	execute "normal! :VWS " .. '/ _\w\{1,}/' .. "\<CR>"
	execute "normal! :lopen\<CR>"	
	# -----------------------------------------------------------------
	# Add first search result to list
	# -----------------------------------------------------------------
	g:is_search_result = search(' _\w\{1,}', "W")
	if (g:is_search_result != 0)
		execute "normal! lviwyel"
		g:subcode_list = g:subcode_list + [@@]	
		while (g:is_search_result != 0)
			g:is_search_result = search(' _\w\{1,}', "W")
			if (g:is_search_result != 0)
				execute "normal! lviwyel"
				g:subcode_list = g:subcode_list + [@@]
			endif 
		endwhile
	endif
	# -----------------------------------------------------------------
	# Need to change the list to a string so it can be pasted into a
	# buffer.
	# -----------------------------------------------------------------
	g:subcode_list_as_string = string(g:subcode_list)
	# -----------------------------------------------------------------
	# Open new buffer; delete its contents and replace them with
	# g:subcode_list_as_a_string; sort the buffer keeping unique values
	# and delete the top line which is a blank line; save the file writing
	# over top of what's there (!); close the Location List and close the
	# 'new' buffer without saving. (You saved the content of this buffer
	# to a file.
	# -----------------------------------------------------------------
	execute "normal! :sp new\<CR>"
	execute "normal! ggVGd:put=" .. g:subcode_list_as_string .. "\<CR>"
	execute "normal! :sort u\<CR>dd"
	execute "normal! :w! " .. g:subcode_dictionary_path .. "\<CR>"
	execute "normal! \<C-w>k:lclose\<CR>\<C-w>j:q!\<CR>"
enddef

def CorrectAttributeLines() 
	
	ParmCheck()

	# Change the pwd to that of the current wiki.
	execute "normal! :cd %:p:h\<CR>"
	# get a list of all the files and directories in the pwd. note the
	# fourth argument that is 1 makes it return a list. the first argument
	# '.' means the current directory and the second argument '*' means
	# all.
	g:file_list_all = globpath('.', '*', 0, 1)
	# build regex we'll use just to find our interview files. 
	g:file_regex = g:interview_label_regex '.md'
	#  cull the list for just those files that are interview files. the
	#  match is at position 2 because the globpath function prefixes
	#  filenames with/ which occupies positions 0 and 1.
	g:interview_list = []
	for list_item in range(0, (len(g:file_list_all) - 1))
		if (match(g:file_list_all[list_item], g:file_regex) == 2) 
			# strip off the leading/
			g:file_to_add = g:file_list_all[list_item][2:]
			g:interview_list = g:interview_list + [g:file_to_add]
		endif
	endfor
	# save buffer number of current file to register 'a' so you can return here
	@a = bufnr('%')
	# go through the list of files copying modifying the attribute line.
	for interview in range(0, (len(g:interview_list) - 1))
		# go to interview file
		execute "normal :e " g:interview_list[interview] .. "\<CR>"
		# copy first row which should be the attribute tags.
		execute "normal! :1,1s/:/: :/g\<CR>"
		execute "normal! :1,1s/^: :/:/\<CR>"
		execute "normal! :1,1s/: :$/:/\<CR>"
	endfor
enddef

def Fix() 
	execute "normal! :1,1s/:/: :/g\<CR>"
	execute "normal! :1,1s/^: :/:/\<CR>"
	execute "normal! :1,1s/: :$/:/\<CR>"
enddef

