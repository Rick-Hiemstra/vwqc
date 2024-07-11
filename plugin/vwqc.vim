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
# Version Vim9_1.0 
# 2024-07-11 
#
# -----------------------------------------------------------------
# ------------------------ TO DO ------------------------------
# -----------------------------------------------------------------
# Update page help
#
# Write a function to modify the attribute lines in the old wikis.
#
# Change Vimwiki so g:current_tags is only deepcopied if it is an interview
# wiki. 
#
# Change the Gather() function so that it will give you an error message if
# you try to use it in a non-quotes report (or other kind of buffer).
#
# Create a backup restore function
#
# Remove the .swp files from backups
#
# Deal with the case where a wiki is configured with a path that doesn't end 
# with a /
#
# Add a popup on exit to prompt a backup, or make a backup automatic.
#
# Find the older :\
#
# Fix up the stuff with g:block_lines_nr you should be able to fix this when
# g:block_lines is first defined and then change instances of g:block_lines_nr
# back to g:block_lines to make the code cleaner to read.
# 
# Write a function that pops up a reminder to do a backup if the last back up
# is more than a few days old.
# 
# Write a function that duplicates a file and allows you to rename it.
#
# Add ability to sift reports by attribute.

# -----------------------------------------------------------------
# ------------------------ FUNCTIONS ------------------------------
# -----------------------------------------------------------------
#
# ---- Setup ----
# HelpMenu
# ProjectSetup
# CreateDefaultInterviewHeader
# GetVWQCProjectParameters
# ParmCheck
# ListProjectParameters
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
# AllSummariesFull
# AllSummariesGenReportsFull
# AllSummariesQuotes
# AllSummariesGenReportsQuotes
# AllSummariesAnnos
# AllSummariesGenReportsAnnos
# GenSummaryLists
# GenInterviewLists
# Gather
# CreateListOfInterviewsWithAnnos
# FilterInterviewList
# CreateAndCountInterviewBlocks
# BuildListOfTagsOnBlock
# TidyUpBlockText
# WriteReportTable
# Report
#
# GetInterviewFileList
# GetAnnotationFileList
# CrawlInterviewTags
# CrawlAnnotationTags
# CalcInterviewTagCrosstabs
# FindLargestTagAndBlockCounts
# PrintInterviewTagSummary
# PrintTagInterviewSummary
# GraphInterviewTagSummary
# GraphTagInterviewSummary
# CreateUniqueInterviewTagList
# FindLengthOfLongestTag
# TagStats
#
# ---- Trimming Quotes ----
# TrimLeadingPartialSentence
# TrimTrailingPartialSentence
# TrimLeadingAndTrailingPartialSentence
#
# ---- Tags ----
# augroup Has_WWQC_Config_Been_Loaded
# TagsLoadedCheck
# GetTagUpdate
# UpdateCurrentTagsPage 
# UpdateCurrentTagsList
# TagsGenThisSession
# ToggleDoubleColonOmniComplete
# GenDictTagList
# CreateTagDict
# CurrentTagsPopUpMenu
# FindLastTagAddedToBuffer
# TagFillWithChoice
# FillTagBlock
# CreateFillLine
# FindFirstInterviewLine
# CreateBlockMetadataDict
# CreateSubBlocksLists
# BuildMetadataBlockFill
# AddFillTags
# FindUpperTagFillLine
# WriteInFormattedTagMetadata
# ProcessLineMetadata
# ChangeTagFillOption
# SortTagDefs
# GetTagDef
# GetTagUnderCursor
# AddNewTagDef
# 
# ---- Attributes ----
# Attributes
# ColSort
#
# ---- Other ----
# UpdateSubcode
# OmniCompleteFileName() 


# -----------------------------------------------------------------
# ---------------------------- VWQC SETUP -------------------------
# -----------------------------------------------------------------

g:tag_regex = '\(^\|\s\)\zs:\([^:''[:space:]]\+:\)\+\ze\(\s\|$\)' 
g:tag_rx = ':\a.\{-}:' 
g:tag_meta_rx = ':\S\{-}:'

# ------------------------------------------------------
# Displays a popup help menu
# ------------------------------------------------------
def g:HelpMenu()
	var help_list = [             "NAVIGATION", 
		                        "<leader>gt                          Go to",
					"<leader>gb                          Go back", 
				 	"<F7>                                Annotation Toggle", 
				        " ", 
				     	"CODING", 
					"<F2>                                Update tags", 
					"<F8>                                Omni-complete (tags and files), same as <F9>",
					"<F9>                                Omni-complete (tags and files), same as <F8>",
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
					":call Gather(\"<tag>\")               Create secondary tag sub-report", 
					":call AllSummariesFull()            Create FullReport summaries for all tags in tag glossary", 
					":call AllSummariesQuotes()          Create QuotesReport summaries for all tags in tag glossary", 
					":call AllSummariesAnnos()           Create AnnotationsReport summaries for all interviews and all tags in tag glossary", 
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
					":call ExportTags()                  Export tags to CSV file",
					"<leader>rs                          Resize windows",
					"<leader>bk                          Create project backup",
					"<leader>tl                          Current tags popup",
					"<leader>hm                          Help menu",
					"<leader>ph                          Page help",
				        "<leader>lp                          List project parameters"]
	popup_menu(help_list, 
				 { minwidth: 50,
				 maxwidth: 120,
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
		execute "normal! O## <Project Title> ##\n\n## Apparatus ##\n\n[Tag Glossary](Tag Glossary)\n[Tag List Current](Tag List Current)\n"
		execute "normal! i[Attributes](Attributes)\n[Style Guide](Style Guide)\n\n## Interviews ##\n"
		execute "normal! i\no = Needs to be coded; p = in process; x = first pass done; z = second pass done\n\n"
		execute "normal! i[o] \n[o] \n[o] \n[o] \n\n## Summary Reports ##\n\n"
		execute "normal! i[Summary Interviews - Full Reports](Summary Interviews - Full Reports)\n"
		execute "normal! i[Summary Interviews - Quotes Reports](Summary Interviews - Quotes Reports)\n"
		execute "normal! i[Summary Interviews - Annotations Reports](Summary Interviews - Annotations Reports)\n"
		execute "normal! i[Summary Tag Stats - Tables - By Interview](Summary Tag Stats - Tables - By Interview)\n"
		execute "normal! i[Summary Tag Stats - Tables - By Tag](Summary Tag Stats - Tables - By Tag)\n"
		execute "normal! i[Summary Tag Stats - Charts - By Interview](Summary Tag Stats - Charts - By Interview)\n"
		execute "normal! i[Summary Tag Stats - Charts - By Tag](Summary Tag Stats - Charts - By Tag)\n"

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
	
	#g:text_col_width_expression          = "set formatprg=par\\ w" .. g:text_col_width
	g:text_col_width_expression          = "set formatprg=fmt\\ -" .. g:text_col_width
	
	g:border_offset                      = g:text_col_width + 3
	g:border_offset_less_one	     = g:border_offset - 1
	g:label_offset                       = g:border_offset + 2

	# Get the label regular expression for this wiki
	g:interview_label_regex  = g:vimwiki_wikilocal_vars[g:wiki_number]['interview_label_regex']
	g:tag_search_regex       = g:interview_label_regex .. '\: \d\{4}'
	
	g:project_name           = g:vimwiki_wikilocal_vars[g:wiki_number]['name']

	g:extras_path = substitute(g:vimwiki_wikilocal_vars[g:wiki_number]['path'], '[^\/]\{-}\/$', "", "g")
	       	.. g:project_name .. "_extras/"

	g:backup_path = substitute(g:vimwiki_wikilocal_vars[g:wiki_number]['path'], '[^\/]\{-}\/$', "", "g") 
		.. g:project_name .. " Backups/"

	# If header template location is explicitly defined then use it, otherwise use default file.
	var has_template = 0
	#has_template = has_key("g:" ..  g:current_wiki_name .. ", 'interview_header_template')\<CR>"
	execute "normal! :let has_template = has_key(g:" ..  g:current_wiki_name .. ", 'interview_header_template')\<CR>"
	if (has_template == 1) 
		execute "normal! :let g:vimwiki_wikilocal_vars[g:wiki_number]['interview_header_template'] = g:"
		       	.. g:current_wiki_name .. ".interview_header_template\<CR>" 
		g:int_header_template    = expand(g:vimwiki_wikilocal_vars[g:wiki_number]['interview_header_template'])
	else
		g:int_header_template    = expand(g:extras_path .. "interview_header_template.txt")
	endif
	
	# If subcode dictionary location is explicitly defined then use it, otherwise use default file.
	var has_sub_code_dict = 0
	execute "normal! :let has_sub_code_dict = has_key(g:" .. g:current_wiki_name .. ", 'subcode_dictionary')\<CR>"
	if (has_sub_code_dict == 1)
		execute "normal! :let g:vimwiki_wikilocal_vars[g:wiki_number]['subcode_dictionary'] = g:" 
			.. g:current_wiki_name .. ".subcode_dictionary\<CR>" 
		g:subcode_dictionary_path    = expand(g:vimwiki_wikilocal_vars[g:wiki_number]['subcode_dictionary'])
	else
		g:subcode_dictionary_path    = expand(g:extras_path .. "subcode_dictionary.txt")
	endif

	# If tag summaries directory is explicitly defined use it, otherwise use the default directory
	var has_tag_sum_path = 0
	execute "normal! :let has_tag_sum_path = has_key(g:" ..  g:current_wiki_name .. ", 'tag_summaries')\<CR>"
	if (has_tag_sum_path == 1)
		execute "normal! :let g:vimwiki_wikilocal_vars[g:wiki_number]['tag_summaries'] = g:" 
			.. g:current_wiki_name .. ".tag_summaries\<CR>" 
		g:tag_summaries_path       = expand(g:vimwiki_wikilocal_vars[g:wiki_number]['tag_summaries'])
	else
		g:tag_summaries_path       = expand(g:extras_path .. "tag_summaries/")
	endif

	g:glossary_path                    = g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. "Tag Glossary.md"

	g:has_coder = 0
	execute "normal! :let g:has_coder = has_key(g:" .. g:current_wiki_name .. ", 'coder_initials')\<CR>"
	if (g:has_coder == 1)
		execute "normal! :let g:vimwiki_wikilocal_vars[g:wiki_number]['coder_initials'] = g:" 
			.. g:current_wiki_name .. ".coder_initials\<CR>" 
       		g:coder_initials           = g:vimwiki_wikilocal_vars[g:wiki_number]['coder_initials']
	else
       		g:coder_initials           = "Unknown coder"
	endif

	g:wiki_extension   	   = g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
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
		bad_label_error_message = proposed_label ..
		       	" does not conform to the " .. 
			g:vimwiki_wikilocal_vars[g:wiki_number]['interview_label_regex'] .. 
		        " label regular expression from the VWQC configuration. Interview formatting aborted."	
		confirm(bad_label_error_message, "Got it", 1)
	endif
enddef

# -----------------------------------------------------------------
# This function formats interview text to use in for Vimwiki interview coding. 
# -----------------------------------------------------------------
def FormatInterviewB(interview_label: string) 

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
	execute "normal! :set formatprg=fmt\\ -w\\ " .. g:text_col_width .. "\<CR>"
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
	
	var current_buffer_name = expand('%:t')
	var is_interview        = match(current_buffer_name, g:interview_label_regex)
	var is_annotation       = match(current_buffer_name, g:interview_label_regex .. ': \d\d\d\d')
	var is_summary          = match(current_buffer_name, 'Summary ')
	var page_help_list      = []

	if current_buffer_name == "index" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		page_help_list = [              
			        "INDEX HELP PAGE", 
		                "The index page is your project home page. You can return to this page by typing <leader>ww in normal mode.",
		                "From here you can create new pages for interviews or summary pages.",
		                " ",
		                "Summary pages, pages that summarize specific tags, must begin with the word \"Summary\" .. ",
		                "Interview pages must be named according to the regular expression (regex) defined in your project parameters. ",
		                "Press <leader>lp in normal mode to list project parameters. ",
		                " ",
			        "Click on this window to close it"]
		DisplayPageHelp(page_help_list)
	elseif current_buffer_name == "Attributes" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		page_help_list = [              
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
		DisplayPageHelp(page_help_list)
	elseif current_buffer_name == "Tag List Current" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		page_help_list = [              
			        "TAG LIST CURRENT HELP PAGE", 
		                "This lists current project tags. It is generated or updated by pressing F2",
		                " ",
			        "Click on this window to close it"]
		DisplayPageHelp(page_help_list)
	elseif current_buffer_name == "Tag Glossary" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		page_help_list = [              
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
		DisplayPageHelp(page_help_list)
	elseif is_annotation == 0
		page_help_list = [              
			        "ANNOTATION HELP PAGE", 
		                "Use F7 to toggle an annotation page open and closed",
		                " ",
			        "Click on this window to close it"]
		DisplayPageHelp(page_help_list)
	elseif is_interview == 0
		page_help_list = [              
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
		DisplayPageHelp(page_help_list)
	elseif is_summary == 0
		page_help_list = [              
			        "SUMMARY HELP PAGE", 
				 ":call FullReport(\"<tag>\")           Create report with tagged and annotation content",
				 ":call QuotesReport(\"<tag>\")         Create report with just tagged content",
				 ":call AnnotationsReport(\"<tag>\")    Create report with just annotation content", 
		                " ",
		                "Quoted lines can also be re-tagged within a report. These re-taggings"
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
		DisplayPageHelp(page_help_list)
	endif

enddef

def DisplayPageHelp(page_help_list: list<string>) 
	popup_menu(page_help_list, 
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
		g:copy_command  = 'cp -R "' .. g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. '" "' .. g:new_backup_path .. '"'
		g:clean_up_swo = 'rm -f "' .. g:new_backup_path .. '"' .. '.*.swo'
		g:clean_up_swp = 'rm -f "' .. g:new_backup_path .. '"' .. '.*.swp'
		g:clean_up_swn = 'rm -f "' .. g:new_backup_path .. '"' .. '.*.swn'
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

	var list_of_tags_on_line    = ""
	var is_tag_on_line          = 1
	var this_tag                = "Undefined"
	var current_line            = line(".")
	var match_line              = -1
	var match_col               = 0
	var current_window_width    = 0
	var annotation_window_width = 0
	var current_time            = strftime("%Y-%m-%d %H\:%M")

	execute "normal! 0"
	# -----------------------------------------------------------------
	# Loop until no more tags are found on the line.
	# -----------------------------------------------------------------
	while (is_tag_on_line == 1)
		# --------------------------------------------------
		# Search for a tag without going past the end of the file.
		# --------------------------------------------------
		match_line = search(g:tag_rx, "W")
		# --------------------------------------------------
		# If we found a tag (ie. The search function doesn't
		# return a zero) and that tag is found on the current line
		# then add the tag to our list. Note search will move the
		# cursor to the first character of the match.
		# --------------------------------------------------
		if (match_line == current_line)
			# -------------------------------------------
			# Copy the tag we found and move the cursor one
			# character past the tag. Then add that tag to the
			# list of tags we're building.
			# -------------------------------------------
			execute "normal! vf:yeel"
			this_tag = getreg('@')
			list_of_tags_on_line = list_of_tags_on_line .. this_tag .. " "
		else
			# No more tags
			is_tag_on_line = 0
		endif 
	endwhile	
	# -----------------------------------------------------------------
	# Move cursor back to the start of current_line because the search
	# function may have moved the cursor beyond current_line
	# -----------------------------------------------------------------
	cursor(current_line, 0)
	execute "normal! 0"
	# -----------------------------------------------------------------
	# Initialize variables and move cursor to the beginning of the line.
	# -----------------------------------------------------------------
	match_line = 0
	match_col = 0
	# -----------------------------------------------------------------
	# Search for the label - number pair on the line. searchpos() 
	# returns a list with the line and column numbers of the cursor
	# position of the first character in the match. searchpos() with
	# the arguments we supplied will move the cursor to the first
	# character of match we found. So because we started in column 1
	# if the column remains at 1 we know we didn't find a match.
	# -----------------------------------------------------------------
	var tag_search_regex = g:interview_label_regex .. '\: \d\{4}'
	var tag_search       = searchpos(g:tag_search_regex)
	match_line           = tag_search[0]
	match_col            = virtcol('.')
	# -----------------------------------------------------------------
	# Now we have to decide what to do with the result based on where
	# the cursor ended up. The first thing we test is whether the match
	# line is the same as the current line. This may not be true if it 
	# had to go down one or more lines to find a match. If its true we
	# execute the first part of the if statement. Otherwise we print an 
	# error message and reposition the cursor at the beginning of the 
	# line where we started.
	# -----------------------------------------------------------------
	if (current_line == match_line)
		# ------------------------------------------------------------------
		#  Figure out how wide we can make the annotation window
		# ------------------------------------------------------------------
		#current_window_width    = winwidth(bufnr('%'))
		current_window_width    = winwidth(win_getid())
		annotation_window_width = current_window_width - g:border_offset - 45
		if (annotation_window_width < 30)
			annotation_window_width = 30
		elseif (annotation_window_width > 80)
			annotation_window_width = 80
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
		if (match_col == g:label_offset)	
			# -----------------------------------------------------------------
			# If its the first annotation in this annotation window
			# -----------------------------------------------------------------
			execute "normal! " .. '0/' .. g:interview_label_regex .. '\:\s\{1}\d\{4}' .. "\<CR>" .. 'vf│hhy'
			execute "normal! gvc[]\<ESC>F[plli()\<ESC>\"\"P\<ESC>" 
			execute "normal \<Plug>VimwikiVSplitLink\<CR>"
			execute "normal! \<C-W>x\<C-W>l:vertical resize " .. annotation_window_width .. "\<CR>"
			put =expand('%:t')
			execute "normal! 0kddgg" 
			search(g:wiki_extension)
			execute "normal! d$I:\<ESC>2o\<ESC>"
		        execute "normal! i[" .. current_time .. "] " .. list_of_tags_on_line .. "// \:" .. g:coder_initials .. "\:  \<ESC>"
			startinsert 
		elseif (match_col == (g:label_offset + 1))
			# -----------------------------------------------------------------
			# For subsequent annotations in this annotation window
			# -----------------------------------------------------------------
			execute "normal! " .. '0/' .. g:interview_label_regex .. '\:\s\{1}\d\{4}' .. "\<CR>"
			execute "normal \<Plug>VimwikiVSplitLink\<CR>"
			execute "normal! \<C-W>x\<C-W>l:vertical resize " .. annotation_window_width .. " \<CR>"
			execute "normal! Go\<ESC>V" .. '?.' .. "\<CR>jd2o\<ESC>"
		        execute "normal! i[" .. current_time .. "] " .. list_of_tags_on_line .. "// \:" .. g:coder_initials .. "\:  \<ESC>"
			startinsert
		else
			echo "Something is not right here."		
		endif
	else
		echo "No match found on this line"
		cursor(current_line, 0)
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
	var test_line = getreg('@')
	# -----------------------------------------------------------------
	# Build a regex that looks for the coder tag at the beginning of the line and
	# then only white space to the carriage return character.
	# -----------------------------------------------------------------
	var find_coder_tag_regex = '\v:' .. g:coder_initials .. ':\s*\n'
	var is_orphaned_tag      = match(test_line, find_coder_tag_regex) 
	# -----------------------------------------------------------------
	# If you don't find anything following the coder tag, ie there is no
	# annotation following, delete the label info generated for this
	# annotation.
	# -----------------------------------------------------------------
	if (is_orphaned_tag > -1)
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
def g:AnnotationToggle() 

	ParmCheck()

	# -----------------------------------------------------------------
	# Initialize buffer type variables
	# -----------------------------------------------------------------
	var is_interview             = 0
	var is_annotation            = 0
	var is_summary               = 0

	var buffer_name              = expand('%:t')
	var where_ext_starts         = strridx(buffer_name, g:wiki_extension)
	buffer_name                  = buffer_name[0 : (where_ext_starts - 1)]
	# -----------------------------------------------------------------
	# Check to see if it is a Summary file. It it is nothing happens.
	# -----------------------------------------------------------------
	if (match(buffer_name, "Summary") > -1)	
		is_summary = 1	
	endif
	# -----------------------------------------------------------------
	# Check to see if the current search result buffer is
	# an annotation file. If it is ExitAnnotation() is called.
	# -----------------------------------------------------------------
	if (match(buffer_name, ' \d\{4}') > -1)     
		is_annotation = 1	
		ExitAnnotation()		
	endif
	# -----------------------------------------------------------------
	# Check to see if the current search result buffer is
	# from an interview file. If it is Annotation() is called.
	# -----------------------------------------------------------------
	if (is_annotation == 0) && (is_summary == 0)
		is_interview = 1		# TRUE
		Annotation()
	endif
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def g:DeleteAnnotation() 
	
	ParmCheck()

	var list_of_tags_on_line    = ""
	var is_tag_on_line          = 1
	var this_tag                = "Undefined"
	var current_line            = line(".")
	var match_line              = -1
	var match_col               = 0
	var col_to_jump_to          = 0
	var current_window_width    = 0
	var annotation_window_width = 0
	var current_time            = strftime("%Y-%m-%d %H\:%M")
	var candidate_delete_buffer = -1

	execute "normal! 0"
	# -----------------------------------------------------------------
	# Search for the label - number pair on the line. searchpos() 
	# returns a list with the line and column numbers of the cursor
	# position of the first character in the match. searchpos() with
	# the arguments we supplied will move the cursor to the first
	# character of match we found. So because we started in column 1
	# if the column remains at 1 we know we didn't find a match.
	# -----------------------------------------------------------------
	var tag_search_regex = g:interview_label_regex .. '\: \d\{4}'
	var tag_search = searchpos(g:tag_search_regex)
	match_line = tag_search[0]
	match_col  = virtcol('.')
	# -----------------------------------------------------------------
	# Now we have to decide what to do with the result based on where
	# the cursor ended up. The first thing we test is whether the match
	# line is the same as the current line. This may not be true if it 
	# had to go down one or more lines to find a match. If its true we
	# execute the first part of the if statement. Otherwise we print an 
	# error message and reposition the cursor at the beginning of the 
	# line where we started.
	# -----------------------------------------------------------------
	if (current_line == match_line)
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
		if (match_col == g:label_offset)
			confirm("No annotation link found on this line.", "OK", 1)
		elseif (match_col == (g:label_offset + 1))
			# -----------------------------------------------------------------
			# Re-find the link, but don't yank it. This places the 
			# cursor on the first character of the match. The next
			# line follows the link to the page.
			# -----------------------------------------------------------------
			execute "normal! " .. '0/' .. g:interview_label_regex .. '\:\s\{1}\d\{4}' .. "\<CR>"
			execute "normal \<Plug>VimwikiVSplitLink"
			execute "normal! :vertical resize " .. annotation_window_width .. "\<CR>"
			candidate_delete_buffer = bufnr("%")
			execute "normal \<Plug>VimwikiDeleteFile"
			# if bufwinnr() < 0 then the buffer doesn't exist.
			if (bufwinnr(candidate_delete_buffer) < 0)
				execute "normal! :q\<CR>"
				execute "normal! " .. match_line .. "G"
				col_to_jump_to = match_col - 1
				set virtualedit=all
				# the lh at the end should probably be \|
				execute "normal! 0" .. col_to_jump_to .. "lh"
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
		cursor(current_line, 0)
	endif
enddef

# -----------------------------------------------------------------
# Finds a label-line number pair in a Summary buffer and uses that to to to
# that location in an interview buffer.
# -----------------------------------------------------------------
def g:GoToReference() 
	
	ParmCheck()

	var target_file = "Undefined"
	var target_line = "Undefined"
	# -----------------------------------------------------------------
	# Change the pwd to that of the current wiki.
	# -----------------------------------------------------------------
	execute "normal! :cd %:p:h\<CR>"
	# -----------------------------------------------------------------
	# Find target file name.
	# -----------------------------------------------------------------
	execute "normal! 0/" .. g:interview_label_regex .. ':\s\d\{4}' .. "\<CR>" .. 'vf:hy'
	target_file = getreg('@') .. g:wiki_extension
	# -----------------------------------------------------------------
	# Find target line number "
	# -----------------------------------------------------------------
	execute "normal! `<"
	execute "normal! " .. '/\d\{4}' .. "\<CR>"
	execute "normal! viwy"
	target_line = getreg('@')
	# -----------------------------------------------------------------
	# Use Z mark to know how to get back
	# -----------------------------------------------------------------
	execute "normal! mZ"
	# -----------------------------------------------------------------
	# Go to target file
	# -----------------------------------------------------------------
	execute "normal :e " .. target_file .. "\<CR>"
	execute "normal! gg"
	# -----------------------------------------------------------------
	# Find line number and center on page
	# -----------------------------------------------------------------
	execute "normal! gg"
	search(target_line)
	execute "normal! zz"
enddef

# -----------------------------------------------------------------
# Returns to the place called by GoToReference().
# -----------------------------------------------------------------
def g:GoBackFromReference() 
	execute "normal! `Zzz`Z"
enddef

# -----------------------------------------------------------------
# ---------------------------- REPORTS ----------------------------
# -----------------------------------------------------------------

def g:FullReport(search_term: string, attr_filter = "none")
	g:Report(search_term, "FullReport", attr_filter)
	execute "normal! \<C-w>o"
enddef

def g:AnnotationsReport(search_term: string)
	g:Report(search_term, "AnnotationsReport") 
	execute "normal! \<C-w>o"
enddef

def g:QuotesReport(search_term: string)
	g:Report(search_term, "QuotesReport") 
	execute "normal! \<C-w>o"
enddef

# -----------------------------------------------------------------
# This function produces summary reports for all tags defined in the 
# tag glossary.
# -----------------------------------------------------------------
def g:AllSummariesFull(attr_filter = "none") 

	ParmCheck()
	execute "normal! :cd %:p:h\<CR>"

	g:attr_filter       = attr_filter
	g:attr_filter_check = 0

	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)

		if (attr_filter != "none")
			g:attr_filter_check = AttrFilterValueCheck(attr_filter)
		endif

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
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
	
enddef


# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def g:AllSummariesGenReportsFull(id: number, result: number)
	set lazyredraw
	
	execute "normal! :e Summary Interviews - Full Reports" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
	# Delete what is there
	execute "normal! ggVGd"

	if result == 2
		execute "normal! :delmarks Q\<CR>mQ"
		confirm("Generating these summary reports will likely take a long time.",  "OK", 1)
		for index in range(0, g:tags_list_length - 1)
			execute "normal! :e " .. g:summary_file_list[index] .. "\<CR>"
			g:FullReport(g:in_both_lists[index], g:attr_filter)
		endfor
		execute "normal! `Q"
		put =g:summary_link_list
		execute "normal! `Q"
	endif

	execute "normal! \<C-w>o"
	set nolazyredraw
	redraw
enddef

# -----------------------------------------------------------------
# This function produces summary reports for all tags defined in the 
# tag glossary.
# -----------------------------------------------------------------
def g:AllSummariesQuotes() 

	ParmCheck()
	execute "normal! :cd %:p:h\<CR>"
	
	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)

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
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
	
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def g:AllSummariesGenReportsQuotes(id: number, result: number)
	set lazyredraw

	execute "normal! :e Summary Interviews - Quotes Reports" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
	# Delete what is there
	execute "normal! ggVGd"

	if result == 2
		execute "normal! :delmarks Q\<CR>mQ"
		confirm("Generating these summary reports will likely take a long time.",  "OK", 1)
		for index in range(0, g:tags_list_length - 1)
			execute "normal! :e " g:summary_file_list[index] .. "\<CR>"
			g:QuotesReport(g:in_both_lists[index])
		endfor
		execute "normal! `Q"
		put =g:summary_link_list
		execute "normal! `Q"
	endif

	execute "normal! \<C-w>o"
	set nolazyredraw
	redraw
enddef

# -----------------------------------------------------------------
# This function produces summary reports for all tags defined in the 
# tag glossary.
# -----------------------------------------------------------------
def g:AllSummariesAnnos() 

	ParmCheck()
	execute "normal! :cd %:p:h\<CR>"

	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)

		g:interview_list = []
		g:interview_list_without_ext = []

		GetInterviewFileList() 
		g:interview_list_length = len(g:interview_list)

		for index in range(0, len(g:interview_list) - 1 )
			g:interview_list_without_ext[index] = g:interview_list[index][ : -g:ext_len]
		endfor
		
		g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')

		if g:tags_list_length > 0
			GenSummaryLists("Annotations")
		endif
		
		if len(g:interview_list) > 0
			GenInterviewLists("Annotations")
		endif

		g:summary_file_list = g:summary_file_list 
		g:summary_link_list = g:summary_link_list
		g:anno_list_tags_and_interviews = g:in_both_lists + g:interview_list_without_ext
		#g:summary_file_list = g:summary_file_list + g:interview_file_list
		#g:summary_link_list = g:summary_link_list + g:interview_link_list
		#g:anno_list_tags_and_interviews = g:in_both_lists + g:interview_list_without_ext

		#g:tags_list_length = len(g:summary_file_list)
		g:tags_list_length = len(g:in_both_lists)

		if (g:tags_generated == 1) && (g:tags_list_length > 0)
			popup_menu(["No, abort", "Yes, generate summary reports"], {
				 title:    "Running this function will erase older \"Annotation\" versions of these reports. Do you want to continue?",
				 callback: 'AllSummariesGenReportsAnnos', 
				 highlight: 'Question',
				 border:     [],
				 close:      'click', 
				 padding:    [0, 1, 0, 1], })
		else
			confirm("Either tags have not been generate for this session or there are no tags to create reports for.",  "OK", 1)

		endif
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
	
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def g:AllSummariesGenReportsAnnos(id: number, result: number)
	set lazyredraw

	execute "normal! :e Summary Interviews - Annotations Reports" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
	# Delete what is there
	execute "normal! ggVGd"
	
	if result == 2
		execute "normal! :delmarks Q\<CR>mQ"
		confirm("Generating these summary reports will likely take a long time.",  "OK", 1)
		for index in range(0, g:tags_list_length - 1)
			execute "normal! :e " .. g:summary_file_list[index] .. "\<CR>"
			g:AnnotationsReport(g:in_both_lists[index])
		endfor
		execute "normal! `Q"
		put =g:summary_link_list
		execute "normal! `Q"
	endif

	execute "normal! \<C-w>o"
	set nolazyredraw
	redraw
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
# Generated list of file names from the g:interview_list.
# -----------------------------------------------------------------
def GenInterviewLists(summary_type: string) 
	var file_name = "undefined"
	var link_name = "undefined"
	g:interview_file_list = []
	g:interview_link_list = []
	for interview_index in range(0, (len(g:interview_list) - 1))
		file_name = "Summary " .. g:interview_list_without_ext[interview_index] .. " " .. summary_type .. " batch" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext']
		link_name = "[Summary " .. g:interview_list_without_ext[interview_index] .. " " .. summary_type .. " batch](Summary " .. g:interview_list_without_ext[interview_index] .. " " .. summary_type .. " batch)"
		g:interview_file_list = g:interview_file_list + [file_name]
		g:interview_link_list = g:interview_link_list + [link_name]
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

	while (search(g:search_term, "W") != 0)
		if match(getline("."), g:tag_search_regex) > 0
			@s = getreg('s') .. getline(".") .. "\n\n"
		else
			execute "normal! ?{\<CR>V/}\<CR>y"
			@s = getreg('s') .. getreg('@') .. "\n"
			execute "normal! `>"
		endif	
	endwhile

	@s = getreg('s') .. "# END THEME: " .. search_term ..  "\n\n"
	execute "normal! `R\"sp"
enddef

def CreateListOfInterviewsWithAnnos()
	for anno in range(0, (len(g:anno_list) - 1))
		g:interview_connected_to_this_anno = matchstr(g:anno_list, g:interview_label_regex)
		if (index(g:list_of_interviews_with_annos, g:interview_connected_to_this_anno) == -1)
			g:list_of_interviews_with_annos = g:list_of_interviews_with_annos + [ g:interview_connected_to_this_anno ]
		endif
	endfor
enddef

def FilterInterviewList(attr_filter: string): list<string>
	var filtered_interview_list = []
	var interview_with_ext      = "undefined"
	for interview in range(0, (len(g:attr_list) - 1))
		if (index(g:attr_list[interview][1], ':' .. attr_filter .. ':') > -1)
			interview_with_ext      = g:attr_list[interview][0] .. g:wiki_extension
			filtered_interview_list = filtered_interview_list + [ interview_with_ext ]
		endif
	endfor
	return filtered_interview_list
enddef

def FilterAttrList(attr_filter: string): list<any>
	var filtered_attr_list = []
	for interview in range(0, (len(g:attr_list) - 1))
		if (index(g:attr_list[interview][1], ':' .. attr_filter .. ':') > -1)
			filtered_attr_list = filtered_attr_list + [ g:attr_list[interview] ]
		endif
	endfor
	return filtered_attr_list
enddef

# -----------------------------------------------------------------
# g:tags_list is a list of tags with the following sub-elements:
# 0) Interview name
# 1) Buffer line number the tag is on
# 2) The tag
# 3) Interview line number the tag is on
# 4) All the tags on the line
# 5) The line text less metadata.
# -----------------------------------------------------------------
def g:CreateAndCountInterviewBlocks(search_term: string, attr_filter: string)
	g:block_first_line      = "Undefined"
	g:block_last_line       = "Undefined"
	g:last_line             = -1
	g:block_text            = "Undefined"
	g:last_interview        = "Undefined"
	var has_key             = "False"
	g:list_of_tags_on_block = []
	
	# g:tag_count_dict
	# The keys will be the interview names
	# 	0 is the tag count
	# 	1 is the block count
	# 	2 is the space to keep track of the last tag's interview line number, 
	# 	3 is a boolean (represented by a 0 or 1 indicating if you're tracking a tag block or not. 
	# 	4 is a space to keep track of the last tag's interview name 
	# This will count and keep track of the tag and block counts. We'll also use it to create blocks
	g:tag_count_dict       = {}
	g:initial_tag_dict     = {}
	
	# g:quote_blocks_dict
	# The keys will be the interview names
	# 	0 Each value will be a list of quote blocks.
	# 	1 is a list of tags associated with the current block being processed
	# 	2 is the first interview line number of the block
	# 	3 is the last interview line number of the block
	g:quote_blocks_dict    = {}

	if (attr_filter != "none")
		g:filtered_interview_list = FilterInterviewList(attr_filter)
		g:filtered_attr_list      = FilterAttrList(attr_filter)
	else
		g:filtered_interview_list = g:interview_list
		g:filtered_attr_list      = g:attr_list
	endif

	#Create an interview dict with the values for each key being a
	# copy of the initial_tag_dict
	for interview in range(0, (len(g:filtered_interview_list) - 1))
		g:interview_less_extension = g:filtered_interview_list[interview][ : -g:ext_len]
		g:tag_count_dict[g:interview_less_extension]    = [0, 0, 0, 0]
		g:quote_blocks_dict[g:interview_less_extension] = []
	endfor

	for index in range(0, len(g:tags_list) - 1)
		# if the current tag we're processing equals the search term
	
		g:current_interview  = g:tags_list[index][0] .. g:wiki_extension
		g:attr_filter_as_tag = ':' .. attr_filter .. ':'
		echom "current interview: " .. g:current_interview .. " and index number " .. index .. " Attn_filter: " .. g:attr_filter_as_tag .. "\n"

		if (g:tags_list[index][2] == ':' .. search_term .. ':') && 
				(index(g:filtered_interview_list, g:current_interview) > -1) &&
				(index(g:tags_list[index][4], g:attr_filter_as_tag) > -1)
			if (g:tags_list[index][0] == g:last_interview)
				# Increment the tag count for this tag
				g:tag_count_dict[g:tags_list[index][0]][0] = g:tag_count_dict[g:tags_list[index][0]][0] + 1
				# if tags_list row number minus row number minus the correspondent tag tracking number isn't 1, i.e. non-contiguous
				if ((g:tags_list[index][1] - g:tag_count_dict[g:tags_list[index][0]][2]) != 1)
					# if the block count isn't 0 i.e. there are blocks
					if g:tag_count_dict[g:tags_list[index][0]][1] != 0
						TidyUpBlockText()
						# Add the block to the block list for this interview dictionary value
						g:quote_blocks_dict[g:tags_list[index][0]] = g:quote_blocks_dict[g:tags_list[index][0]] + [ g:block_text ]
					endif
					#Mark that you've entered a block 
					g:tag_count_dict[g:tags_list[index][0]][3] = 1
					#Increment the block counter for this interview
					g:tag_count_dict[g:tags_list[index][0]][1] = g:tag_count_dict[g:tags_list[index][0]][1] + 1
					#Record the first line number of this block
					g:block_first_line      = g:tags_list[index][3]
					g:last_line             = g:tags_list[index][3]
					g:last_interview        = g:tags_list[index][0]
					g:list_of_tags_on_line  = g:tags_list[index][4]
					g:list_of_tags_on_block = g:tags_list[index][4]
					# add to the quoteblocks
					g:block_text            = g:tags_list[index][5]
				else
					# Reset the block counter because you're inside a block now. 
					g:tag_count_dict[g:tags_list[index][0]][3] = 0
					# Add this line to the g:block_text
					g:block_text            = g:block_text .. g:tags_list[index][5]
					g:last_line             = g:tags_list[index][3]
					g:last_interview        = g:tags_list[index][0]
					g:list_of_tags_on_line  = g:tags_list[index][4]
					BuildListOfTagsOnBlock()
				endif
				# Set the last line for this kind of tag equal to the line of the tag we've been considering in this loop.
				g:tag_count_dict[g:tags_list[index][0]][2] = g:tags_list[index][1]
			elseif (g:last_interview != "Undefined") && (g:tags_list[index][0] != g:last_interview)
				# if the block count isn't 0 i.e. there are blocks
				# Check to see if the interview exists
				if g:tag_count_dict[g:last_interview][1] != 0
					TidyUpBlockText()
					# Add the block to the block list for this interview dictionary value
					g:quote_blocks_dict[g:last_interview] = g:quote_blocks_dict[g:last_interview] + [ g:block_text ]
				endif
				# Increment the tag count for this tag
				g:tag_count_dict[g:tags_list[index][0]][0] = g:tag_count_dict[g:tags_list[index][0]][0] + 1
				# if tags_list row number minus row number minus the correspondent tag tracking number isn't 1, i.e. non-contiguous
				#Mark that you've entered a block 
				g:tag_count_dict[g:tags_list[index][0]][3] = 1
				#Increment the block counter for this interview
				g:tag_count_dict[g:tags_list[index][0]][1] = g:tag_count_dict[g:tags_list[index][0]][1] + 1
				#Record the first line number of this block
				g:block_first_line      = g:tags_list[index][3]
				g:last_line             = g:tags_list[index][3]
				g:last_interview        = g:tags_list[index][0]
				g:list_of_tags_on_line  = g:tags_list[index][4]
				g:list_of_tags_on_block = g:tags_list[index][4]
				# add to the quoteblocks
				g:block_text            = g:tags_list[index][5]
				# Set the last line for this kind of tag equal to the line of the tag we've been considering in this loop.
				g:tag_count_dict[g:tags_list[index][0]][2] = g:tags_list[index][1]
			else
				# Increment the tag counter
				g:tag_count_dict[g:tags_list[index][0]][0] = g:tag_count_dict[g:tags_list[index][0]][0] + 1
				#Increment the block counter for this interview
				g:tag_count_dict[g:tags_list[index][0]][1] = g:tag_count_dict[g:tags_list[index][0]][1] + 1
				#Mark that you've entered a block 
				g:tag_count_dict[g:tags_list[index][0]][3] = 1
				#Record the first line number of this block
				g:block_first_line      = g:tags_list[index][3]
				g:last_line             = g:tags_list[index][3]
				g:last_interview        = g:tags_list[index][0]
				g:list_of_tags_on_line  = g:tags_list[index][4]
				g:list_of_tags_on_block = g:tags_list[index][4]
				# add to the quoteblocks
				g:block_text            = g:tags_list[index][5]
				g:tag_count_dict[g:tags_list[index][0]][2] = g:tags_list[index][1]
			endif
		endif 
	endfor
	TidyUpBlockText()
	g:quote_blocks_dict[g:last_interview] = g:quote_blocks_dict[g:last_interview] + [ g:block_text ]
enddef

def BuildListOfTagsOnBlock()
	for tag_index in range(0, len(g:list_of_tags_on_line) - 1)
		if (index(g:list_of_tags_on_block, g:list_of_tags_on_line[tag_index]) == -1)
			g:list_of_tags_on_block = g:list_of_tags_on_block + [ g:list_of_tags_on_line[tag_index] ]
		endif
	endfor
enddef

def TidyUpBlockText()
	# Take out extra spaces
	g:block_text = substitute(g:block_text, '\s\+', ' ', "g")
	# Take out time stamps and speaker labels. This may be AWS Transcribe specific
	g:block_text = substitute(g:block_text, '(\d:\d\d:\d\d)\sspk_\d:\s', '', "g") 
	g:block_text = substitute(g:block_text, "\'\'", "\'", "g") 
	g:cross_codes_string = string(g:list_of_tags_on_block)
	g:cross_codes_string = substitute(g:cross_codes_string, "\'", ' ', "g")
	g:cross_codes_string = substitute(g:cross_codes_string, ',', '', "g")
	g:cross_codes_string = substitute(g:cross_codes_string, '\s\+', ' ', "g")
	g:block_text = g:block_text .. " **" .. g:last_interview .. ": "
	       	.. g:block_first_line .. " - " .. g:last_line .. "** " .. g:cross_codes_string .. "\n\n"
enddef 

# g:tag_count_dict
# The keys will be the interview names
#	0 is the tag count
#	1 is the block count
#	2 is the space to keep track of the last tag's interview line number, 
#	3 is a boolean (represented by a 0 or 1 indicating if you're tracking a tag block or not. 
def WriteReportTable(search_term: string)

	g:search_term_with_colons = ":" .. search_term .. ":"
	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")

	var total_tags   	  = 0
	var total_blocks 	  = 0
	var total_annos  	  = 0
	var ave_block_size        = "Undefined"
	var ave_total_blocks_size = "Undefined"
	var interview_name        = "Undefined"
	var interview_num         = 0

	execute "normal! i|No.|Interview|Block Count|Tag Count|Tags / Blocks|Annotations| \n"
	execute "normal! ki\<ESC>j"
	execute "normal! i|---:|:---|---:|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"

	for interview in range(0, len(g:filtered_interview_list) - 1)
		interview_name = g:filtered_interview_list[interview][ : -g:ext_len]		
	
		g:number_of_annos = 0
		for anno_index in range(0, len(g:anno_tags_dict[g:filtered_interview_list[interview][ : -g:ext_len]]) - 1)
			if (index(g:anno_tags_dict[g:filtered_interview_list[interview][ : -g:ext_len]][anno_index][1], g:search_term_with_colons) != -1)
				g:number_of_annos = g:number_of_annos + 1
			endif
		endfor

		# says tag_dict_count is underfined 
		var lines_per_block = printf("%.1f", 1.0 * g:tag_count_dict[g:filtered_interview_list[interview][ : -g:ext_len]][0] / g:tag_count_dict[g:filtered_interview_list[interview][ : -g:ext_len]][1])
		

		
		interview_num = interview + 1
		execute "normal! i| " .. interview_num ..  " | [[" .. g:filtered_interview_list[interview][ : -g:ext_len] .. "]] | " ..
					 g:tag_count_dict[g:filtered_interview_list[interview][ : -g:ext_len]][1] ..  " | " ..
					 g:tag_count_dict[g:filtered_interview_list[interview][ : -g:ext_len]][0] .. " | " .. 
					 lines_per_block .. " | " .. 
					 g:number_of_annos .. " |\n"
		execute "normal! ki\<ESC>j"
		total_tags   = total_tags   + g:tag_count_dict[g:filtered_interview_list[interview][ : -g:ext_len]][0]
		total_blocks = total_blocks + g:tag_count_dict[g:filtered_interview_list[interview][ : -g:ext_len]][1]
		total_annos  = total_annos  + g:number_of_annos
		
	endfor 
	# add total block, line and anno counters here.	
	execute "normal! i|:---|---|---:|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"
	ave_total_blocks_size = printf("%.1f", 1.0 * total_tags / total_blocks)
	execute "normal! i| Totals | | " ..
				 total_tags            .. "|" .. 
				 total_blocks          .. "|" ..
				 ave_total_blocks_size .. "|" ..
				 total_annos           .. "|\n\n"
	execute "normal! 2ki\<ESC>2j"
enddef
# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def g:Report(search_term: string, report_type = "FullReport", attr_filter = "none") 

	ParmCheck()
	
	echom "Search Term: " .. search_term .. "\n"
	var interview_name = "Undefined"
	var attr_string    = "Undefined"
	var search_term_with_colons = ":" .. search_term .. ":"

	execute "normal! :cd %:p:h\<CR>"

	# Clear buffer contents
	execute "normal! ggVGd"

	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)
		g:CreateAndCountInterviewBlocks(search_term, attr_filter)
		
		ReportHeader(report_type, search_term)
		 
		WriteReportTable(search_term)
		# NEED to filter g:anno_tags_list:
		execute "normal! G"
		# Write quote blocks
		for interview in range(0, len(g:filtered_interview_list) - 1)

			# Write quote blocks
			g:interview_name = g:filtered_interview_list[interview][ : -g:ext_len]
			execute "normal! i# " .. repeat("=", 80) .. "\n"
			execute "normal! i# INTERVIEW: " .. g:interview_name .. "\n"
			execute "normal! i# " .. repeat("=", 80) .. "\n"
			#echom interview .. " " .. string(g:attr_list[interview]) .. "\n"
			attr_string = string(g:filtered_attr_list[interview][1])
			attr_string = substitute(attr_string, '[\[\[\],]', '', 'g')
			attr_string = substitute(attr_string, "'", '', 'g')
			execute "normal! i**ATTRIBUTES:** " .. attr_string .. "\n\n"

			if (report_type == "FullReport") || (report_type == "QuotesReport")
				for quote_block in range(0, len(g:quote_blocks_dict[g:interview_name]) - 1)
					execute "normal! i" .. g:quote_blocks_dict[g:interview_name][quote_block] 
				endfor
			endif

			# Write anno blocks
			var anno_counter = 0
			if (report_type == "FullReport") || (report_type == "AnnotationsReport")
				for anno in range(0, len(g:anno_tags_dict[g:interview_name]) - 1)
					if (index(g:anno_tags_dict[g:interview_name][anno][1], search_term_with_colons) != -1)
						anno_counter = anno_counter + 1
						execute "normal! i**" .. repeat(">-", 40) .. "**\n"
						execute "normal! i**" .. g:interview_name .. " ANNOTATION " .. anno_counter .. ":**\n"
						execute "normal! i**" .. repeat(">-", 40) .. "**\n"
						execute "normal! i" .. g:anno_tags_dict[g:interview_name][anno][2] .. "\n"
					endif
				endfor
			endif
		endfor 
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
	execute "normal! gg"
enddef

def GetInterviewFileList() 

	var file_to_add = "undefined"
	execute "normal! :cd %:p:h\<CR>"
	# get a list of all the files and directories in the pwd. Note the
	# fourth argument that is 1 makes it return a list. The first argument
	# '.' means the current directory and the second argument '*' means
	# all.
	var file_list_all = globpath('.', '*', 0, 1)
	# build regex we'll use just to find our interview files. 
	var file_rx = g:interview_label_regex .. g:wiki_extension
	#  cull the list for just those files that are interview files. the
	#  match is at position 2 because the globpath function prefixes
	#  filenames with ./ which occupies positions 0 and 1.
	g:interview_list = []
	for list_item in range(0, (len(file_list_all) - 1))
		if (match(file_list_all[list_item], file_rx) == 2) 
			# strip off the leading/
			file_to_add = file_list_all[list_item][2 : ]
			g:interview_list = g:interview_list + [ file_to_add ]
		endif
	endfor
enddef

def GetAnnotationFileList() 

	var file_to_add = "undefined"
	execute "normal! :cd %:p:h\<CR>"
	# get a list of all the files and directories in the pwd. Note the
	# fourth argument that is 1 makes it return a list. The first argument
	# '.' means the current directory and the second argument '*' means
	# all.
	var file_list_all = globpath('.', '*', 0, 1)
	# build regex we'll use just to find our interview files. 
	var file_rx = g:interview_label_regex .. ': \d\{4}' .. g:wiki_extension
	#  cull the list for just those files that are interview files. the
	#  match is at position 2 because the globpath function prefixes
	#  filenames with ./ which occupies positions 0 and 1.
	g:anno_list = []
	for list_item in range(0, (len(file_list_all) - 1))
		if (match(file_list_all[list_item], file_rx) == 2) 
			# strip off the leading/
			file_to_add = file_list_all[list_item][2 : ]
			g:anno_list = g:anno_list + [ file_to_add ]
		endif
	endfor
enddef

# -----------------------------------------------------------------
# g:tags_list is a list of tags with the following sub-elements:
# 0) Interview name
# 1) Buffer line number the tag is on
# 2) The tag
# 3) Interview line number the tag is on
# 4) All the tags on the line
# 5) The line text less metadata.
# -----------------------------------------------------------------
def CrawlInterviewTags(interview: number, interview_name: string) 
	var end_line             = line('$')
	var tag_being_considered = "undefined"
	var interview_attrs      = []
	# move through each line testing for tags and removing duplicate tags
	# on each line
	call cursor(1, 1)

	g:tags_on_line = []

	for line in range(1, end_line)
		#cursor(line, 0)
		# search() returns 0 if match not found
		g:tag_test = search(g:tag_rx, 'c', line("."))
		if (g:tag_test != 0)
			# Copy found tag
			execute "normal! viWy"
			g:tags_on_line = g:tags_on_line + [ getreg('@') ]
			execute "normal! l"
			g:tag_test = search(g:tag_rx, '', line("."))
			while (g:tag_test != 0)
				execute "normal! viWy"
				tag_being_considered = getreg('@')
				g:have_tag = 0
				if (index(g:tags_on_line, tag_being_considered) > -1)
					g:have_tag = 1
				endif
				# if we have the tag, delete it
				if (g:have_tag == 1)
					execute "normal! gvx"
				else
					g:tags_on_line = g:tags_on_line + [ getreg('@') ]
				endif
				#execute "normal! l"
				g:tag_test = search(g:tag_rx, '', line("."))
			endwhile
		endif
		# Add tags found on line to g:tags_list
		var line_text           = getline(".")
		var interview_line_num  = matchstr(line_text, ': \d\{4}')[2 : ]
		line_text = line_text[0 : (g:text_col_width + 1)]

		var processed_line_1 = 0
		for tag_index in range(0, len(g:tags_on_line) - 1)
			if (line == 1)
				if (processed_line_1 == 0)
					g:attr_list = g:attr_list + [[interview_name, g:tags_on_line]]
					interview_attrs = g:tags_on_line
					processed_line_1 = 1
				endif
			else
				g:tags_list = g:tags_list + [[interview_name, line, g:tags_on_line[tag_index], interview_line_num, g:tags_on_line, line_text, interview_attrs]]
			endif
		endfor
		# Go to start of next line
		execute "normal! j0"
		g:tags_on_line = []
	endfor	
enddef

# -----------------------------------------------------------------
# g:anno_tags_list is a list of tags with the following sub-elements:
# 0) Interview name
# 1) Line number in the annotation is attached to in the interview
# 2) A list of tags found in the annotation
# 3) The text of the annotation
# -----------------------------------------------------------------
def CrawlAnnotationTags(anno_num: number, anno_name: string) 

	var tag_being_considered = "undefined"
	execute "normal! gg"

	var top_line            = getline('.')
	var interview           = matchstr(top_line, g:interview_label_regex)
	var line_num_as_string  = matchstr(top_line, ': \d\{4}')[2 : ]
	
	g:tags_in_anno = []
	for line in range(2, line('$'))
		# search() returns 0 if match not found
		g:tag_test = search(g:tag_rx, 'W')
		if (g:tag_test != 0)
			# Copy found tag
			execute "normal! viWy"
			g:tags_in_anno = g:tags_in_anno + [ getreg('@') ]
			g:tag_test = search(g:tag_rx, 'W')
			while (g:tag_test != 0)
				execute "normal! viWy"
				tag_being_considered = getreg('@')
				g:have_tag = 0
				# loop to see if we already have this tag
				if (index(g:tags_in_anno, tag_being_considered) == -1)
					g:tags_in_anno = g:tags_in_anno + [ tag_being_considered ]
				endif 
				g:tag_test = search(g:tag_rx, 'W')
			endwhile
		endif
	endfor	
	execute "normal! ggVGy"
	g:anno_tags_dict[interview] = g:anno_tags_dict[interview] + [[ line_num_as_string, g:tags_in_anno, getreg('@') ]]
enddef
# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def CalcInterviewTagCrosstabs(unique_tags: list<string>, interview_list: list<string>, ext_length: number): dict<any>
	#build the data structure that will hold the interview-tag crosstabs
	g:tag_count_dict       = {}
	g:initial_tag_dict     = {}

	for index in range(0, (len(interview_list) - 1)) 
		interview_list[index] = interview_list[index][ : ext_length]
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
	#Create an interview dict with a the values for each key being a
	# copy of the initial_tag_dict
	for interview in range(0, (len(interview_list) - 1))
		g:tag_count_dict[interview_list[interview]] = deepcopy(g:initial_tag_dict)
	endfor

	for index in range(0, len(g:tags_list) - 1)
		# Increment the tag count for this tag
		g:tag_count_dict[g:tags_list[index][0]][g:tags_list[index][2]][0] = g:tag_count_dict[g:tags_list[index][0]][g:tags_list[index][2]][0] + 1
		# if tags_list row number minus row number minus the
		# correspondent tag tracking number isn't 1, i.e. non-contiguous
		if ((g:tags_list[index][1] - g:tag_count_dict[g:tags_list[index][0]][g:tags_list[index][2]][2]) != 1)
			#Mark that you've entered a block 
			g:tag_count_dict[g:tags_list[index][0]][g:tags_list[index][2]][3] = 1
			#Increment the block counter for this tag
			g:tag_count_dict[g:tags_list[index][0]][g:tags_list[index][2]][1] = g:tag_count_dict[g:tags_list[index][0]][g:tags_list[index][2]][1] + 1
		else
			# Reset the block counter because you're
			# inside a block now. There is no need to
			# increment the block counter.
			g:tag_count_dict[g:tags_list[index][0]][g:tags_list[index][2]][3] = 0
		endif
		# Set the last line for this kind of tag equal to the line of the tag we've been considering in this loop.
		g:tag_count_dict[g:tags_list[index][0]][g:tags_list[index][2]][2] = g:tags_list[index][1]
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
def PrintInterviewTagSummary(interview: string) 
	var total_tags            = 0
	var total_blocks          = 0
	var ave_block_size        = "Undefined"
	var ave_total_blocks_size = "Undefined"

	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Interview " .. interview .. " tag summary last updated at " .. report_update_time .. "**\n\n"
	execute "normal! i|Tag|Tag Count|Block Count|Average Block Size| \n"
	execute "normal! ki\<ESC>j"
	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"

	for tag_index in range(0, (len(g:unique_tags) - 1))

		ave_block_size = printf("%.1f", 1.0 * g:tag_cross[interview][g:unique_tags[tag_index]][0] / g:tag_cross[interview][g:unique_tags[tag_index]][1])
		execute "normal! i|" .. g:unique_tags[tag_index] .. "|" .. 
					 g:tag_cross[interview][g:unique_tags[tag_index]][0] .. "|" .. 
					 g:tag_cross[interview][g:unique_tags[tag_index]][1] .. "|" ..
					 ave_block_size        .. "|\n"
		execute "normal! ki\<ESC>j"
		total_tags   = total_tags   + g:tag_cross[interview][g:unique_tags[tag_index]][0]
		total_blocks = total_blocks + g:tag_cross[interview][g:unique_tags[tag_index]][1]
	endfor

	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"
	#ave_total_blocks_size = printf("%.1f", str2float(total_tags) / str2float(total_blocks))
	ave_total_blocks_size = printf("%.1f", 1.0 * total_tags / total_blocks)
	execute "normal! i| Totals |" .. 
				 total_tags            .. "|" .. 
				 total_blocks          .. "|" ..
				 ave_total_blocks_size .. "|\n\n"
	execute "normal! 2ki\<ESC>2j"
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def PrintTagInterviewSummary(tag_: string, interview_list: list<string>) 
	var total_tags   = 0
	var total_blocks = 0
	var ave_block_size = "Undefined"
	var ave_total_blocks_size = "Undefined"

	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Tag " .. tag_ .. " tag summary last updated at " .. report_update_time .. "**\n\n"
	execute "normal! i|Interview|Tag Count|Block Count|Average Block Size| \n"
	execute "normal! ki\<ESC>j"
	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"

	for interview_index in range(0, (len(interview_list) - 1))
		ave_block_size = printf("%.1f", 1.0 *
		       	g:tag_cross[interview_list[interview_index]][tag_][0] / g:tag_cross[interview_list[interview_index]][tag_][1])
		execute "normal! i|" interview_list[interview_index] .. "|" .. 
					 g:tag_cross[interview_list[interview_index]][tag_][0] .. "|" .. 
					 g:tag_cross[interview_list[interview_index]][tag_][1] .. "|" ..
					 ave_block_size     ..    "|\n"
		execute "normal! ki\<ESC>j"
		total_tags   = total_tags   + g:tag_cross[interview_list[interview_index]][tag_][0]
		total_blocks = total_blocks + g:tag_cross[interview_list[interview_index]][tag_][1]
	endfor

	execute "normal! i|:---|---:|---:|---:|\n"
	execute "normal! ki\<ESC>j"
	ave_total_blocks_size = printf("%.1f", 1.0 * total_tags / total_blocks)
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
def GraphInterviewTagSummary(interview: string, longest_tag_length: number, bar_scale: float) 
	var bar_scale_print = printf("%.1f", bar_scale)
	var offset          = 0
	var block_amount    = 0
	var tag_amount      = 0

	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Graph: Interview " .. interview .. "** (Updated: " .. report_update_time .. ")\n"

	for tag_index in range(0, (len(g:unique_tags) - 1))
		offset       = longest_tag_length - len(g:unique_tags[tag_index])
		block_amount = g:tag_cross[interview][g:unique_tags[tag_index]][1]
		tag_amount   = g:tag_cross[interview][g:unique_tags[tag_index]][0] - block_amount
		if g:tag_cross[interview][g:unique_tags[tag_index]][0] != 0
			execute "normal! i" .. g:unique_tags[tag_index] .. " " .. repeat(" ", offset) ..
							"|" .. repeat('□', str2nr(string(round(block_amount * bar_scale)))) .. 
							repeat('▤', str2nr(string(round(tag_amount * bar_scale)))) ..
						 	" " .. g:tag_cross[interview][g:unique_tags[tag_index]][0] .. 
							"(" .. g:tag_cross[interview][g:unique_tags[tag_index]][1] .. ")\n"
		else
			execute "normal! i" .. g:unique_tags[tag_index] .. " " .. repeat(" ", offset) .. "|\n"
		endif
	endfor
	execute "normal! iLegend: □ = coding block bar over top of tag bar. ▤ = tag bar.\n"
	execute "normal! iScale: " .. bar_scale_print .. " square characters represent 1 observation.\n\n"
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def GraphTagInterviewSummary(tag_: string, longest_tag_length: number, bar_scale: float) 
	var bar_scale_print = printf("%.1f", bar_scale)
	var offset          = 0
	var block_amount    = 0
	var tag_amount      = 0

	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! Gi**Graph: Tag " .. tag_ .. "** (Updated: " .. report_update_time .. ")\n"

	for interview_index in range(0, (len(g:interview_list) - 1))
		offset       = longest_tag_length - len(g:interview_list[interview_index])
		block_amount = g:tag_cross[g:interview_list[interview_index]][tag_][1]
		tag_amount   = g:tag_cross[g:interview_list[interview_index]][tag_][0] - block_amount
		if g:tag_cross[g:interview_list[interview_index]][tag_][0] != 0
			execute "normal! i" .. g:interview_list[interview_index] .. " " .. repeat(" ", offset) ..
							"|" .. repeat('□', str2nr(string(round(block_amount * bar_scale)))) .. 
							repeat('▤', str2nr(string(round(tag_amount * bar_scale)))) ..
						 	" " .. g:tag_cross[g:interview_list[interview_index]][tag_][0] .. 
							"(" .. g:tag_cross[g:interview_list[interview_index]][tag_][1] .. ")\n"
		else
			execute "normal! i" .. g:interview_list[interview_index] .. " " .. repeat(" ", offset) .. "|\n"
		endif
	endfor
	execute "normal! iLegend: □ = coding block bar over top of tag bar. ▤ = tag bar.\n"
	execute "normal! iScale: " .. bar_scale_print .. " square characters represent 1 observation.\n\n"
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def CreateUniqueInterviewTagList()
	g:unique_tags = []
	for index in range(0, len(g:tags_list) - 1)
		if (index(g:unique_tags, g:tags_list[index][2]) == -1)
			g:unique_tags = g:unique_tags + [g:tags_list[index][2]]
		endif
	endfor
enddef 

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def CreateUniqueAnnoTagList()
	var interview_name = "Undefined"
	g:unique_anno_tags = []
	for interview in range(0, len(g:interview_list) - 1)
		interview_name = g:interview_list[interview][ : -g:ext_len]		
		for anno in range(0, len(g:anno_tags_dict[interview_name]) - 1)
			for sub_index in range(0, len(g:anno_tags_dict[interview_name][anno][1]) - 1)
				if (index(g:unique_anno_tags, g:anno_tags_dict[interview_name][anno][1][sub_index][1 : -2]) == -1)
					g:unique_anno_tags = g:unique_anno_tags + [ g:anno_tags_dict[interview_name][anno][1][sub_index][1 : -2] ]
				endif
			endfor
		endfor
	endfor 
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
	
	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)

		var ext_length = (len(g:vimwiki_wikilocal_vars[g:wiki_number]['ext']) + 1) * -1
		var interview_to_crawl = "Undefined"

		# save buffer number of current file to register 'a' so you can return here
		g:buffer_to_return_to = bufnr('%')
		
		g:interview_list = []
		GetInterviewFileList()

		g:tags_list = []
		g:attr_list = []
		
		# Go through each interview file building up a list of tags
		for interview in range(0, (len(g:interview_list) - 1))
			# go to interview file
			execute "normal :e " .. g:interview_list[interview] .. "\<CR>"
			interview_to_crawl = expand('%:t:r')
			CrawlInterviewTags(interview, interview_to_crawl)	
		endfor

		#Creates the g:unique_tags list 
		CreateUniqueInterviewTagList()
		sort(g:unique_tags)

		g:tag_cross   = CalcInterviewTagCrosstabs(g:unique_tags, g:interview_list, ext_length)
		
		# Find the longest tag in terms of the number of characters in the tag.
		g:len_longest_tag           = FindLengthOfLongestTag(g:unique_tags)
		g:len_longest_interview_tag = len(g:interview_list[0]) 

		g:window_width = winwidth(win_getid())

		# Find the largest tag and block tallies. This will be used in the scale calculation for graphs.
		# Multiplying by 1.0 is done to coerce integers to floats.
		g:largest_tag_and_block_counts = FindLargestTagAndBlockCounts(g:tag_cross, g:unique_tags, g:interview_list, ext_length)
		g:largest_tag_count            = g:largest_tag_and_block_counts[0] * 1.0
		g:largest_block_count          = g:largest_tag_and_block_counts[1] * 1.0

		# find the number of digits in the following counts. Used for
		# calculating the graph scale. The nested functions are mostly to
		# convert the float to an int. Vimscript doesn't have a direct way to do this.
		g:largest_tag_count_digits    = str2nr(string(trunc(log10(g:largest_tag_count) + 1)))
		g:largest_block_count_digits  = str2nr(string(trunc(log10(g:largest_block_count) + 1)))

		g:max_bar_width = g:window_width - g:len_longest_tag - g:largest_tag_count_digits - g:largest_block_count_digits - 10
		g:bar_scale     = g:max_bar_width / g:largest_tag_count

		# Return to the buffer where these charts and graphs are going to be
		# produced and clear out the buffer.
		execute "normal! :b" .. g:buffer_to_return_to .. "\<CR>gg"

		set lazyredraw

		execute "normal! :e Summary Tag Stats - Tables - By Interview" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
		execute "normal! ggVGd"

		# Print interview tag summary tables
		for interview in range(0, (len(g:interview_list) - 1))
			PrintInterviewTagSummary(g:interview_list[interview])	
		endfor

		execute "normal! :e Summary Tag Stats - Tables - By Tag" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
		execute "normal! ggVGd"

		#Print tag interview summary tables
		for tag_index in range(0, (len(g:unique_tags) - 1))
			PrintTagInterviewSummary(g:unique_tags[tag_index], g:interview_list)
		endfor

		execute "normal! :e Summary Tag Stats - Charts - By Interview" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
		execute "normal! ggVGd"

		# Print interview tag summary graphs
		for interview in range(0, (len(g:interview_list) - 1))
			GraphInterviewTagSummary(g:interview_list[interview], g:len_longest_tag, g:bar_scale)	
		endfor

		execute "normal! :e Summary Tag Stats - Charts - By Tag" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
		execute "normal! ggVGd"

		# Print interview tag summary graphs
		for tag_index in range(0, (len(g:unique_tags) - 1))
			GraphTagInterviewSummary(g:unique_tags[tag_index], g:len_longest_interview_tag, g:bar_scale)	
		endfor
		
		set nolazyredraw
		redraw

		# Return to the buffer where these charts and graphs are going to be
		# produced and clear out the buffer.
		execute "normal! :b" .. g:buffer_to_return_to .. "\<CR>gg"

		confirm("Tag stats have been updated. Access tag stats pages from the index page", "OK", 1)
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def ReportHeader(report_type: string, search_term: string) 
	var report_update_time = strftime("%Y-%m-%d %H:%M:%S (%a)")
	execute "normal! i# " .. repeat("*", 80) .. "\n# " .. repeat("*", 80) .. "\n"
	execute "normal! i**" .. report_type 
		.. "(\"" .. search_term .. "\")**\nCreated by **" 
	        .. g:coder_initials .. "**\non **" 
		.. report_update_time .. "**\n"
		.. "using tag list generated at " .. g:tag_update_time .. "\n"

	execute "normal! i# " .. repeat("*", 80) .. "\n# " .. repeat("*", 80) .. "\n\n"
        execute "normal! i**SUMMARY TABLE:**\n\n" 
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def g:TrimLeadingPartialSentence() 
	execute "normal! 0v)hx"
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def g:TrimTrailingPartialSentence() 
	execute "normal! $"
	g:trim_tail_regex = '**' .. g:tag_search_regex
	g:tag_test = search(g:trim_tail_regex, 'b', line("."))
	execute "normal! hv(d0"
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def g:TrimLeadingAndTrailingPartialSentence() 
	g:TrimLeadingPartialSentence()
	g:TrimTrailingPartialSentence()
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
def g:GetTagUpdate() 

	ParmCheck()

	g:vimwiki_wikilocal_vars[g:wiki_number]['tags_generated_this_session'] = 1

	confirm("Populating tags. This may take a while.", "Got it", 1)

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

	var ext_length = (len(g:vimwiki_wikilocal_vars[g:wiki_number]['ext']) + 1) * -1
	var interview_to_crawl = "Undefined"

	# save buffer number of current file to register 'a' so you can return here
	g:buffer_to_return_to = bufnr('%')
	
	g:interview_list = []
	GetInterviewFileList()

	g:anno_list = []
	GetAnnotationFileList()

	g:tags_list = []
	g:attr_list = []
	
	# Go through each interview file building up a list of tags
	for interview in range(0, (len(g:interview_list) - 1))
		# go to interview file
		execute "normal :e " .. g:interview_list[interview] .. "\<CR>"
		interview_to_crawl = expand('%:t:r')
		CrawlInterviewTags(interview, interview_to_crawl)	
	endfor
	
	var anno_to_crawl = "Undefined"
	g:anno_tags_dict  = {}
	g:initial_interview_anno_dict = []

	for interview in range(0, (len(g:interview_list) - 1))
		g:interview_less_extension = g:interview_list[interview][ : -g:ext_len]
		g:anno_tags_dict[g:interview_less_extension]  = []
	endfor

	# Go through each annotation file building up a list of tags
	for annotation in range(0, (len(g:anno_list) - 1))
		# go to interview file
		execute "normal :e " .. g:anno_list[annotation] .. "\<CR>"
		anno_to_crawl = expand('%:t:r')
		CrawlAnnotationTags(annotation, anno_to_crawl)	
	endfor

	#Creates the g:unique_tags list 
	CreateUniqueInterviewTagList()
	sort(g:unique_tags)

	CreateUniqueAnnoTagList()
	sort(g:unique_anno_tags)
	
	g:current_tags = []
	for index in range(0, (len(g:unique_tags) - 1))
		g:current_tags = g:current_tags + [g:unique_tags[index][1 : -2]]
	endfor

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
	UpdateCurrentTagsPage()
	g:Attributes()
	g:CurrentTagsPopUpMenu()

	g:current_tags = sort(g:just_in_dict_list + g:just_in_current_tag_list + g:in_both_lists)

	# ------------------------------------------------------
	# Add an element to the current wiki's configuration dictionary that
	# marks it as having had its tags generated in this vim session.
	# ------------------------------------------------------
	execute "normal! `Yzz"
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
	#execute "normal! :e " .. g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. "Tag List Current" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
	execute "normal! :e Tag List Current" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
	# Delete what is there
	execute "normal! ggVGd"
	g:tag_update_time = strftime("%Y-%m-%d %a %H:%M:%S")
	execute "normal! i**Tag list last updated at: " .. g:tag_update_time .. "**\n\<CR>"
	execute "normal! i- **There are " .. len(g:in_both_lists) .. " tag(s) defined in the Tag Glossary and used in interview buffers.**\n"
	put =g:in_both_lists
	execute "normal! Go"
	execute "normal! i\n- **There are " .. len(g:just_in_current_tag_list) .. " tag(s) used in interview buffers, but not defined in the Tag Glossary.**\n"
	put =g:just_in_current_tag_list
	execute "normal! Go"
	execute "normal! i\n- **There are " .. len(g:just_in_dict_list) .. " tag(s) defined in the Tag Glossary but not used in interview buffers.**\n"
	put =g:just_in_dict_list
	execute "normal! Go"
	execute "normal! i\n- **There are " .. len(g:unique_anno_tags) .. " tag(s) that appear in annotations.**\n"
	put =g:unique_anno_tags
	execute "normal! ggj"
	# Return to where you were
	execute "normal! `Rzz"
	execute "normal! \<C-w>o"
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def UpdateCurrentTagsList() 
	var is_in_list = -1
	var print_list_item = "undefined"
	g:tag_dict_keys 		= keys(g:tag_dict)
	g:tag_dict_keys 		= sort(g:tag_dict_keys, 'i')
	
	g:tag_list_output               = []
	g:in_both_lists  		= []
	g:just_in_dict_list		= []
	g:just_in_current_tag_list	= []

	for tag_dict_tag in range(0, (len(g:tag_dict_keys) - 1))
		is_in_list = index(g:current_tags, g:tag_dict_keys[tag_dict_tag])
		if (is_in_list >= 0)
			print_list_item = g:tag_dict_keys[tag_dict_tag]
			g:in_both_lists = g:in_both_lists + [ print_list_item ]
		elseif (is_in_list == -1)
			print_list_item = g:tag_dict_keys[tag_dict_tag]
			g:just_in_dict_list = g:just_in_dict_list + [ print_list_item ]
		endif
	endfor

	for current_tag in range(0, (len(g:current_tags) - 1))
		is_in_list = index(g:tag_dict_keys, g:current_tags[current_tag])
		if (is_in_list == -1)
			print_list_item = g:current_tags[current_tag]
			g:just_in_current_tag_list = g:just_in_current_tag_list + [ print_list_item ]
		endif
	endfor

	g:tag_list_output = ["DEFINED IN TAG GLOSSARY AND USED IN INTERVIEW BUFFERS:", " "] + g:in_both_lists + [" ", "UNDEFINED IN TAG GLOSSARY:", " "] + g:just_in_current_tag_list + [" ", "DEFINED IN TAG GLOSSARY BUT NOT USED IN INTERVIEW BUFFERS:", " "] + g:just_in_dict_list 
	#g:tag_list_output = sort(g:tag_list_output)
enddef

# ------------------------------------------------------
# This is what populates the omnicomplete for tags. ie <F8>.
# ------------------------------------------------------
def g:TagsGenThisSession() 
	
	ParmCheck()

	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)

		# -----------------------------------------------------------------
		# Change the pwd to that of the current wiki.
		# -----------------------------------------------------------------
		execute "normal! :cd %:p:h\<CR>"
		# ------------------------------------------------------
		# See if the wiki config dictionary has had a
		# tags_generated_this_session key added.
		# ------------------------------------------------------
		# The ! after startinsert makes it insert after (like A). If
		# you don't have the ! it inserts before (like i)
		# ------------------------------------------------------
		startinsert!
		feedkeys("\<c-x>\<c-o>", 'i')
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
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
 		if (has_key(g:tag_dict, g:current_tags[tag_index]))
			g:dict_tags = g:dict_tags + [ g:current_tags[tag_index] ]
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
	execute "normal! :e" .. g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. "Tag Glossary" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
	execute "normal! gg"
	# -----------------------------------------------------------------
	# Define an empty tag dictionary
	# -----------------------------------------------------------------
	g:tag_dict = {}
	# -----------------------------------------------------------------
	# Build the tag dictionary. 
	# -----------------------------------------------------------------
	while (search('{', "W") > 0)
		execute "normal! j$bviWy0"
		var tag_key = getreg('@')
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
def g:CurrentTagsPopUpMenu() 
	popup_menu(g:tag_list_output, 
				 { minwidth: 70,
				 maxwidth: 70,
				 pos: 'center',
				 border: [],
				 close: 'click',
				 })
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
	g:cl = []
	
	g:cl = getchangelist()
	
	var len_cl     = len(g:cl[0])
	var index_inv  = 0 
	g:line_has_tag = []

	for index in range(0, len_cl - 1)
		index_inv = len_cl - 1 - index
		g:line_has_tag = matchstrpos(getline(g:cl[0][index_inv]['lnum']), g:tag_regex .. '\(.*:\S\{-}:\)\@!')
		if (g:line_has_tag[1] > -1)
			g:most_recent_tag_in_changes = g:line_has_tag[0][1 : -2]
			break
		endif
	endfor 
	g:block_tags_list = [ g:most_recent_tag_in_changes ]
		
enddef

def g:TagFillWithChoice() 
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
	
	if (g:tag_fill_option == "bottom of contiguous block")
		g:block_tags_list = []
	endif 

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
	#g:tag_search_regex = g:interview_label_regex .. '\: \d\{4}'
	g:first_interview_line = search(g:tag_search_regex, "W")
	cursor(g:bottom_line, g:bottom_col)
enddef
	

def CreateBlockMetadataDict() 

	g:block_metadata             = {}
	g:tags_on_line               = []
	g:sub_blocks_tags_lists      = []
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

	if (g:tag_fill_option == "last tag added")
		g:first_tag       = [ g:block_tags_list[0] ]
		g:rest_of_tags    = g:block_tags_list[1 : ]
		g:rest_of_tags    = sort(g:rest_of_tags)
		g:block_tags_list = g:first_tag + g:rest_of_tags
	#else
	#	g:block_tags_list = sort(g:block_tags_list)
	endif
enddef

def CreateSubBlocksLists() 
	g:sub_blocks_tags_lists = []
	var found_block = 0
	for line_index in range(g:block_lines_nr[0], g:block_lines_nr[-1])
		if (len(g:block_metadata[line_index][2]) != 0) && (found_block == 0)
			g:sub_blocks_tags_lists = g:sub_blocks_tags_lists + [ [ g:block_metadata[line_index][2], [ line_index ] ] ]
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

	g:sub_block_tag_list = []
	g:fill_tag           = g:block_tags_list[result - 1]

	g:block_lines        = sort(keys(g:block_metadata), 'N')

	g:block_lines_nr     = []

	for index in range(0, (len(g:block_lines) - 1))
		g:block_lines_nr[index] = str2nr(g:block_lines[index])
	endfor

	FindUpperTagFillLine()
	AddFillTags()
	CreateSubBlocksLists()

	for line_index in range(g:block_lines_nr[0], g:block_lines_nr[-1])
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
				g:formatted_metadata = g:formatted_metadata .. repeat(' ', len(g:sub_block_tag_list[tag_index]) + 3)
			endif
		endfor

		g:block_metadata[line_index] = g:block_metadata[line_index] + [ g:formatted_metadata .. g:block_metadata[line_index][3] ]
		
		g:block_metadata[line_index][4] = substitute(g:block_metadata[line_index][4], '\s\+$', '', 'g')
		if g:block_metadata[line_index][4] == ""
			g:block_metadata[line_index][4] = "  "
		endif
	endfor
	WriteInFormattedTagMetadata()
enddef

def AddFillTags() 
	for line_index in range(g:upper_fill_line + 1, g:block_lines_nr[-1])
		g:block_metadata[line_index][2] = g:block_metadata[line_index][2] + [ g:fill_tag ]
		g:block_metadata[line_index][2] = sort(g:block_metadata[line_index][2]) 
	endfor
enddef

def FindUpperTagFillLine() 
	for line_index in range(g:block_lines_nr[0], g:block_lines_nr[-1])
		if (index(g:block_metadata[line_index][2], g:fill_tag) != -1)
			g:upper_fill_line = line_index
		endif
	endfor
enddef

def WriteInFormattedTagMetadata() 
	set virtualedit=all
	for line_index in range(g:block_lines_nr[0], g:block_lines_nr[-1])
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
	g:block_metadata[line('.')] = [g:right_border_col, g:right_border_virtcol]
	
	# copy everything beyond the right of the right label pane border.
	execute "normal! lv$y"
	#execute "normal! lvg_y"
	# Tokenize what got copied into a list called g:line_meta_data
	g:line_metadata = split(getreg('@'))
	for index in range(0, len(g:line_metadata) - 1)
		if (match(g:line_metadata[index], g:tag_meta_rx) != -1)
			g:tags_on_line = g:tags_on_line + [ g:line_metadata[index][1 : -2] ]
			if (index(g:block_tags_list, g:line_metadata[index][1 : -2]) == -1)
				g:block_tags_list = g:block_tags_list + [ g:line_metadata[index][1 : -2] ]
			endif
		else
			g:non_tag_metadata = g:non_tag_metadata .. " " .. g:line_metadata[index]
		endif
	endfor
	g:block_metadata[line('.')] = g:block_metadata[line('.')] + [g:tags_on_line, g:non_tag_metadata]
enddef

# ------------------------------------------------------
#
# ------------------------------------------------------
def g:ChangeTagFillOption() 
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
def g:SortTagDefs() 
	execute "normal! :%s/}/}\r/g\<CR>"
	execute "normal! :g/{/,/}/s/\\n/TTTT/\<CR>"
	execute "normal! :1,$sort \i\<CR>"
	execute "normal! " .. ':3,$g/^$/d' .. "\<CR>"
	execute "normal! :%s/TTTT/\\r/g\<CR>"
enddef


# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def g:GetTagDef() 
	
	ParmCheck()

	execute "normal! :cd %:p:h\<CR>"
	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)

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
		
		var tag_check_message = g:tag_to_test .. " is not defined in the Tag Glossary\. Would you like to add it now?"

 		if (g:tag_to_test != "") 
			if (has_key(g:tag_dict, g:tag_to_test))
 				popup_atcursor(get(g:tag_dict, g:tag_to_test), {
 					 'border': [],
 					 'close': 'click',
 					 })
 			else
 				popup_menu(['Yes', 'No'], {
				         title: tag_check_message, 
					 callback: 'AddNewTagDef',
					 highlight: 'Question',
					 minwidth: 50,
					 maxwidth: 100, 
					 pos: "center", 
 					 border: [],
 					 close: 'click',
					 padding: [0, 1, 0, 1] })
			endif
		else
 			popup_atcursor("There is no valid tag under the cursor.", {
 				 'border': [],
 				 'close': 'click',
 				 })
 		endif
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
enddef


# -----------------------------------------------------------------
# See if word under cursor is a tag. ie. a word surrounded by colons
# Test case where the cursor is on white space.
# -----------------------------------------------------------------
def GetTagUnderCursor(): string       
	execute "normal! viWy"        
	var word_under_cursor             = getreg('@') 
	# Want tag_test to be 0
	#var tag_test                      = matchstr(word_under_cursor, ':.\{-}:')
	var tag_test                      = matchstr(word_under_cursor, g:tag_rx)
	# -----------------------------------------------------------------
	# Test to see if g:word_under_cursor is just white space. If not,
	# test to see if the word_under_cursor is surrounded by colons.
	# -----------------------------------------------------------------
	if word_under_cursor == tag_test
		return word_under_cursor[1 : -2]
	else
		return ""
	endif
enddef

# -----------------------------------------------------------------
# 
# -----------------------------------------------------------------
def AddNewTagDef(id: number, result: number) 
	if (result == 1)
		# -----------------------------------------------------------------
		# Save buffer number of current file to register 'a' so you can return here
		# -----------------------------------------------------------------
		execute "normal! :delmarks Z\<CR>"
		execute "normal! mZ"
		# -----------------------------------------------------------------
		# Go to Tag Glossary and create a new tag template populated with the 
		# g:tag_to_test value
		# -----------------------------------------------------------------
		execute "normal! :e" .. g:vimwiki_wikilocal_vars[g:wiki_number]['path'] .. "Tag Glossary" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
		execute "normal! Go{\n## Name: " .. g:tag_to_test .. "\n**Detailed Description:** \n**Incl. Criteria:** \n**Excl. Criteria:** \n**Example:** \n}\<ESC>4kA"
		g:SortTagDefs()
		execute "normal! /Name: " .. g:tag_to_test .. "\<CR>jA"
		confirm("Add your tag description.\n\nWhen you are finished press <F2> to update the tag list.\n\n", "OK", 1)
	endif
enddef

# -----------------------------------------------------------------
# ---------------------------- ATTRIBUTES -------------------------
# -----------------------------------------------------------------

# ------------------------------------------------------
#
# ------------------------------------------------------
def g:Attributes(sort_col = 1) 
	g:attr_line = ""
	ParmCheck()
	execute "normal! :cd %:p:h\<CR>"
	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)
		execute "normal! :e Attributes" .. g:vimwiki_wikilocal_vars[g:wiki_number]['ext'] .. "\<CR>"
		# Delete what is there
		execute "normal! ggVGd"
		# save buffer number of current register so you can return here
		for interview in range(0, (len(g:attr_list) - 1))
			g:attr_line = g:attr_line ..  "| [[" .. g:attr_list[interview][0] .. "]] | "
			for index in range(0, (len(g:attr_list[interview][1]) - 1))
				g:attr_line = g:attr_line .. g:attr_list[interview][1][index][1 : -2] .. " |"
			endfor
			g:attr_line = g:attr_line .. "\n"
		endfor
		# return to page where you're going to print the chart and paste the
		# chart.
		execute "normal! i" .. g:attr_line .. "\<CR>\n"
		execute "normal! Go\<ESC>v?.\<CR>jdgga\<ESC>\<CR>gg"
		ColSort(sort_col)

		g:attr_update_time = strftime("%Y-%m-%d %a %H:%M:%S")
		execute "normal! OATTRIBUTES:\nUpdated at " .. g:attr_update_time .. 
			"\nbased on the " .. g:tag_update_time .. " tag update generated by " .. g:coder_initials .. "\n" .. 
			"sorted by column " .. sort_col .. "\<ESC>"

	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
enddef

def AttrFilterValueCheck(attr_filter: string): number
	var has_attr_filter = 0
	for interview in range(0, (len(g:attr_list) - 1))
		if (index(g:attr_list[interview][1], attr_filter) > -1)
			has_attr_filter = 1
			break
		endif
	endfor
	return has_attr_filter
enddef

# ------------------------------------------------------

# ------------------------------------------------------
# ------------------------------------------------------
# Sort the Attribute table by column number
# ------------------------------------------------------
def ColSort(column = 1) 
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
		g:subcode_list = g:subcode_list + [ getreg('@') ]	
		while (g:is_search_result != 0)
			g:is_search_result = search(' _\w\{1,}', "W")
			if (g:is_search_result != 0)
				execute "normal! lviwyel"
				g:subcode_list = g:subcode_list + [ getreg('@') ]
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


# -----------------------------------------------------------------
# g:tags_list is a list of tags with the following sub-elements:
# 0) Interview name
# 1) Buffer line number the tag is on
# 2) The tag
# 3) Interview line number the tag is on
# 4) All the tags on the line
# 5) The line text less metadata.
# -----------------------------------------------------------------
#  Maybe write everything to a variable and then print all at once.

# Need to trim trailing whitespace off of the linetext value [5]
def g:ExportTags()
	var outline            = ""
	var outfile            = ""
	var today              = strftime("%Y-%m-%d")
	var time_now           = strftime("%H-%M-%S")
	var trimmed_line_text  = ""
	 
	var out_file_name = g:extras_path .. g:project_name .. " tag export made at " .. today .. " " .. time_now .. ".csv"

	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)
		for tag_index in range(0, len(g:tags_list) - 1)
			trimmed_line_text = substitute(g:tags_list[tag_index][5], '\s*$', '', "")
			outline = g:tags_list[tag_index][0] .. ", " ..
			          g:tags_list[tag_index][2] .. ", " ..
			          g:tags_list[tag_index][1] .. ", " ..
			          g:tags_list[tag_index][3] .. ", \"" ..
			          trimmed_line_text         .. "\", " 
			for sub_index in range(0, len(g:tags_list[tag_index][4]) - 1)
				outline = outline 
					.. g:tags_list[tag_index][4][sub_index] .. ", "
			endfor
			outline = outline[ : -2] .. "\n"
			outfile = outfile .. outline
		endfor
		writefile(split(outfile, "\n", 1), out_file_name) 
		confirm("The tags list has been exported to " .. out_file_name, "OK", 1)
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
enddef

def g:OmniCompleteFileName() 
	
	ParmCheck()

	g:tags_generated  = has_key(g:vimwiki_wikilocal_vars[g:wiki_number], 'tags_generated_this_session')
	if (g:tags_generated == 1)

		# -----------------------------------------------------------------
		# Change the pwd to that of the current wiki.
		# -----------------------------------------------------------------
		execute "normal! :cd %:p:h\<CR>"
		# ------------------------------------------------------
		# See if the wiki config dictionary has had a
		# tags_generated_this_session key added.
		# ------------------------------------------------------
		# The ! after startinsert makes it insert after (like A). If
		# you don't have the ! it inserts before (like i)
		# ------------------------------------------------------
		startinsert!
		feedkeys("\<c-x>\<c-f>", 'i')
	else
		confirm("Tags have not been generated for this wiki yet this session. Press <F2> to generate tags.", "OK", 1)
	endif
enddef
