# /packages/intranet-customer-portal/www/upload-files.tcl
#
# Copyright (C) 2011 ]project-open[
# The code is based on ArsDigita ACS 3.4
#
# This program is free software. You can redistribute it
# and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option)
# any later version. This program is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

ad_page_contract {
    @param 
    @author Klaus Hofeditz (klaus.hofeditz@project-open.com)
} {
    {security_token ""}
    {inquiry_id ""}
}

# ---------------------------------------------------------------
# Security & Defaults
# ---------------------------------------------------------------

set page_title "Project Wizard"
set show_navbar_p 0
set show_left_navbar_p 0
set anonymous_p 1
set company_placeholder ""


if { "" != $security_token } {
    if { $inquiry_id == 0} {
	ad_return_complaint 1 "You have to register first in order to upload files. Please refer to our <a href='/intranet-customer-portal/'>Customer Portal</a>"
    }
    set master_file "../../intranet-customer-portal/www/master"
} else {
    set user_id [ad_maybe_redirect_for_registration]
    set anonymous_p 0
    set master_file "../../intranet-core/www/master"

    # If user is member of more than one company, we have to show a combo  
    set ctr 0  
    set option_str ""
    set column_sql "
	select 
		a.object_id_one as company_id,  
		(select company_name from im_companies where company_id = a.object_id_one) as company_name 
	from 
		acs_rels a
	where 
		object_id_two = $user_id and 
		rel_type = 'im_company_employee_rel'
    "
    db_foreach col $column_sql {
	incr ctr
	append option_str "<option value='$company_id'>$company_name</option>"
    }
    
    if { 1 < $ctr } {
	append company_placeholder "We have registered you for at least companies. Please choose the one you inquire the quote for:"
	append company_placeholder "<select id=\"company_id\" name=\"company_id\""
	append company_placeholder $option_str
	append company_placeholder </select>
    } elseif { 1 == $ctr } {
	set company_placeholder "<span style='font-size: medium; font-weight: bold'>Company:&nbsp;</span>"
	append company_placeholder "$company_name<br><br>"
	append company_placeholder 
    } 
}

# Load Sencha libs 
template::head::add_css -href "/intranet-sencha/css/ext-all.css" -media "screen" -order "1"
template::head::add_css -href "/intranet-customer-portal/resources/css/BoxSelect.css" -media "screen" -order "2"

# Load SuperSelectBox
template::head::add_javascript -src "/intranet-sencha/js/ext-all-debug-w-comments.js" -order 1
template::head::add_javascript -src "/intranet-customer-portal/resources/js/BoxSelect.js" -order 100

# ---------------------------------------------------------------
# Set HTML elements
# ---------------------------------------------------------------

#Source Language 
set source_language_id 250
set include_source_language_country_locale [ad_parameter -package_id [im_package_translation_id] SourceLanguageWithCountryLocaleP "" 0]
set source_language_combo [im_trans_language_select -include_country_locale $include_source_language_country_locale source_language_id $source_language_id]

#Target Language
# set target_language_ids [im_target_language_ids 0]
# set target_language_combo [im_category_select_multiple -translate_p 0 "Intranet Translation Language" target_language_ids $target_language_ids 12 multiple]

# Delivery Date 


# ---------------------------------------------------------------
# Add customer registration
# ---------------------------------------------------------------

template::head::add_javascript -src "/intranet-customer-portal/resources/js/upload-files-form.js?inquiry_id=$inquiry_id" -order "2"

