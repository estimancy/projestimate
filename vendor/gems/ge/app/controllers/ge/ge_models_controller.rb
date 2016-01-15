# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Ge::GeModelsController < ApplicationController

  require 'rubyXL'

  def show
    authorize! :show_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    set_page_title @ge_model.name
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.name => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @ge_model = Ge::GeModel.new
    set_page_title I18n.t(:new_instance_of_effort)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "effort"), I18n.t(:new) => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    set_page_title I18n.t(:Edit_instance_of_effort)
    #set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.organization => ""
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.name => ""

  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:ge_model][:organization_id])

    @ge_model = Ge::GeModel.new(params[:ge_model])
    @ge_model.organization_id = params[:ge_model][:organization_id].to_i
    if @ge_model.save
      redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    if @ge_model.update_attributes(params[:ge_model])
      redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    organization_id = @ge_model.organization_id

    @ge_model.module_projects.each do |mp|
      mp.destroy
    end

    @ge_model.delete
    redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
  end

  #Delete all factors and factor-values data of the model
  def delete_all_factors_data
    @ge_model = Ge::GeModel.find(params[:ge_model_id])    #For the factors list worksheet
    ge_model_factors = @ge_model.ge_factors
    #ge_factor_values = @ge_model.ge_factor_values

    unless ge_model_factors.nil?
      ge_model_factors.destroy_all
    end
    redirect_to ge.edit_ge_model_path(@ge_model, anchor: "tabs-2")
  end

  # Data export
  # if there is no data, a file with data format will be exported
  def data_export
    authorize! :show_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:ge_model_id])    #For the factors list worksheet
    ge_model_factors = @ge_model.ge_factors
    ge_factor_values = @ge_model.ge_factor_values

    workbook = RubyXL::Workbook.new
    workbook.add_worksheet("Factors")
    workbook.add_worksheet("Values")
    workbook.add_worksheet("Help")

    # add worksheet to workbook
    model_worksheet = workbook[0]
    factors_worksheet = workbook[1]
    values_worksheet = workbook[2]
    help_worksheet = workbook[3]

    model_worksheet.sheet_name = "Model attribute"

    first_page = [[I18n.t(:model_name),  @ge_model.name],
                  #[I18n.t(:model_description), @ge_model.description ],
                  [I18n.t(:three_points_estimation), @ge_model.three_points_estimation ? 1 : 0],
                  [I18n.t(:modification_entry_valur), @ge_model.enabled_input ],
                  ["#{I18n.t(:label_Factor)} a", @ge_model.coeff_a ],
                  ["#{I18n.t(:scale_factor)} : b", @ge_model.coeff_b ],
                  [I18n.t(:retained_size_unit), @ge_model.size_unit],
                  [I18n.t(:Wording_of_the_module_unit_effort_2), @ge_model.effort_unit],
                  [I18n.t(:hour_coefficient_conversion), @ge_model.standard_unit_coefficient],
                  [I18n.t(:advice_ge), ""]]

    first_page.each_with_index do |row, index|
      model_worksheet.add_cell(index, 0, row[0])
      model_worksheet.add_cell(index, 1, row[1]).change_horizontal_alignment('center')
      ["bottom", "right"].each do |symbole|
        model_worksheet[index][0].change_border(symbole.to_sym, 'thin')
        model_worksheet[index][1].change_border(symbole.to_sym, 'thin')
      end
    end
    model_worksheet.change_column_bold(0,true)
    model_worksheet.change_column_width(0, 38)

    factors_default_attributs = ["Scale-Prod", I18n.t(:factor_type), I18n.t(:short_name), I18n.t(:long_name), I18n.t(:description)]
    values_default_attributs = [I18n.t(:factors), I18n.t(:value_text), I18n.t(:value_number), I18n.t(:default_value)]

    factors_counter_line = 1
    factors_default_attributs.flatten.each_with_index do |w_header, index|
      factors_worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
    end
    factors_worksheet.change_row_bold(0,true)
    factors_worksheet.change_column_width(0, 10)

    values_counter_line = 1
    values_default_attributs.flatten.each_with_index do |w_header, index|
      values_worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
    end
    values_worksheet.change_row_bold(0,true)
    values_worksheet.change_column_width(0, 20)

    # For help worksheet
    help_worksheet.add_cell(0, 0, "Quelques remarques concernant la construction de ce fichier : ")
    help_worksheet.change_row_bold(0,true)
    help_worksheet.add_cell(1, 0, "Un attribut ayant une seule valeur n'est pas affiché")
    help_worksheet.add_cell(2, 0, I18n.t(:scale_prod_help))
    help_worksheet.change_row_height(2, 40)

    #fill data if worksheets
    if ge_model_factors.nil? || ge_model_factors.empty?
      #create exemple of the data : factors and factor values
      workbook.add_worksheet("Factors exemples")
      workbook.add_worksheet("Values exemples")
      factors_exple_worksheet = workbook['Factors exemples']
      values_exple_worksheet = workbook['Values exemples']

      help_worksheet.add_cell(4, 0, "Il n'existe pas de donnée de facteurs pour ce module. \nPour vous aider à constituer et à créer vos facteurs et les valeurs associées à ces facteurs, nous avons ajoué 2 onglets pour exemple.")
      help_worksheet.add_cell(5, 0, "L'onglet \"Factors exemples\" contient des exemples de facteurs pour remplir l'onglet \"Factors\". \n")
      help_worksheet.add_cell(6, 0, "L'onglet \"Values exemples\" contient des exemples de valeurs des facteurs pour remplir l'onglet \"Values\". \n")
      help_worksheet.add_cell(8, 0, "Seuls les onglets \"Model attribute\", \"Factors\" et \"Values\" seront pris en compte lors d'un inport depuis l'application. \n Les autres onglets servent d'exemples ou de remarques.")
      help_worksheet.change_row_font_color(8, 'FF0000') #change_row_fill(8, 'FF0000')
      help_worksheet.change_row_height(8, 30)

      factors_exple_counter_line = 1
      factors_default_attributs.flatten.each_with_index do |w_header, index|
        factors_exple_worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
      end
      factors_exple_worksheet.change_row_bold(0,true)
      factors_exple_worksheet.change_column_width(0, 10)

      values_exple_counter_line = 1
      values_default_attributs.flatten.each_with_index do |w_header, index|
        values_exple_worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
      end
      values_exple_worksheet.change_row_bold(0,true)
      values_exple_worksheet.change_column_width(0, 20)

      factors_exple = [
        ["P",	"Facteurs produits", "RELY", "Exigence de fiabilité du logiciel",	"Ce paramètre mesure le niveau de fiabilité exigé, en général sur les applications de gestion  paramètre entre L et H"],
        ["P",	"Facteurs produits", "DATA", "Taille des données nécessaires aux tests", "Mesure es exigences de tests- nbre de règles de gestion, multiplicité des cas à tester"],
        ["P", "Facteurs produits", "CPLX", "Complexité du produit",	"5 types de complexité à prendre en compte : opérations de contrôle, opérations de calcul, opérations dépendantes du hardware, opérations de gestion des données, opérations de gestion de l'interface utilisateur \nValeur = mix de ces différents paramètres"],
        ["P",	"Facteurs produits",	"RUSE", "Développé pour une réutilisation", "La réutilisabilité du composant ou du projet est-elle à prendre en compte dans le coût du développement ?"],
        ["P", "Facteurs produits", "DOCU", "Niveau de la documentation attendue", "La documentation ( exigences, specifications, tests, ...) à fournir lors du développement correspond-elle aux besoins ?"],
        ["P",	"Facteurs techniques", "TIME",	"Contraintes de temps de réponses",	"Le developpement doit prendre en compte des exigences de performance liées à la durée du traitement"],
        ["P",	"Facteurs techniques",	"STOR",	"Contraintes de taille mémoire",	"Le developpement doit prendre en compte des limites en terme de taille méméoire"],
        ["P",	"Facteurs techniques",	"PVOL",	"Stabilité de la plateforme de développement",	"Plateforme de développement, y compris les outils de dev., mais aussi plateforme d'exploitation (OS, DBMS….)"],
        ["P",	"Facteurs projets", "TOOL",	"Utilisation d'outils de développement", "outils de dev et de tests, AGL, gestion de conf, gestion des exigences, planification ..."],
        ["P", "Facteurs projets", "SITE",	"Développement multi sites", "Mix entre la localisation et les moyens de communications"],
        ["P",	"Facteurs projets",	"SCED",	"Contrainte de délai", ""],
        ["P", "Facteurs personnels", "ACAP", "Maîtrise des analystes", "Capacité à analyser et concevoir, efficacité et précision, capacité à communiquer et coopérer"],
        ["P", "Facteurs personnels", "PCAP", "Maîtrise des développeurs", "Jugement sur l'équipe et non sur l'individu, précision, efficacité, capacité à communiquer et coopérer"],
        ["P", "Facteurs personnels", "PCON", "Turn-over du personnel", "taux de turn-over"],
        ["P",	"Facteurs personnels",	"APEX",	"Expérience sur ce type d'application", ""],
        ["P",	"Facteurs personnels",	"PLEX",	"Expérience sur l'environnement technique", ""],
        ["P",	"Facteurs personnels",	"LTEX",	"Expérience sur le langage et les outils de développment", ""],
        ["P",	"NA",	"PBASE",	"Coefficient de base COCOMOII : 2.94", ""],
        ["S",	"Organisation",	"PREC",	"Antériorité",	"Si le projet est comparable à d'autres projets développés antérieurement, alors l'antériorité est élevée (H)"],
        ["S",	"Organisation",	"FLEX",	"Flexibilité plus ou moins forte du respects des exigences (vs délai)",	"Ce paramètre vérifie les besoins de satisfaction des exigences et des interfaces. Si le niveau de flexibilité est important (priorité à la livraison par rapport à la satisfaction rigoureuse des exigences)  la valeur de l'indicateur est XH"],
        ["S",	"Organisation",	"RESL",	"Architecture et Résolution des risques",	"Gestion et suivi des risques, incertitude sur l'architecture et nombre d'architectes sur le projet par rapport aux besoins"],
        ["S",	"Organisation", "TEAM", "Cohésion de l'équipe", "Mesure la difficulté de synchroniser toutes les parties prenantes du projet utilisateurs, clients, développeurs, architectes…"],
        ["S",	"Organisation",	"PMAT",	"Maturité des processus",	"Maturité de l'organisation"],
        ["S",	"NA",	"COCOMO PostArch",	"Coef de base pour Post Architecture", "Coef de base auquel s'ajoute les facteurs d'échelle"],
        ["C",	"Langages",	"LANG",	"Conversion FP-> KSLOC", "Ce paramètre permet de traduire une taille en Points de Fonction IFPUG en Ksloc, en appliquant une table de conversion"],
        ["C",	"Réutilisation", "SIZE", "Taux de réutilisation de code existant", "Permet de prendre en compte un code existant."]
      ]

      factor_values_exple = [
          ["PREC",	"Totalement sans précédent", "0,062", ""],
          ["PREC",	"Largement sans précédent", "0,0496", ""],
          ["PREC",	"Légèrement sans précédent",	"0,0372",	"Default"],
          ["PREC",	"Plutôt familier", "0,0248", ""],
          ["PREC",	"Largement familier", "0,0124", ""],
          ["FLEX",	"conformité générale",	"0,0203", ""],
          ["RESL",	"Peu - 20%",	"0,0707", ""],
          ["TEAM",	"Coopération basique",	"0,0329", ""],
          ["PMAT",	"CMMI - level 2",	"0,0468", ""],
          ["COCOMO PostArch",	"Coef de base pour Post Architecture",	"0,91", ""],
          ["RELY",	"modérée, pertes facilement récupérables", 	"1", ""],
          ["DATA",	"Besoin important",	"1,14", ""],
          ["CPLX",	"Complexité de base",	"1", ""],
          ["RUSE",	"Pas de réutilisation", "0,95", ""],
          ["DOCU",	"documentation adaptée", "1", ""],
          ["TIME",	"< = 50% du temps disponible",	"1", ""],
          ["STOR",	"< = 50% de l'espace disponible",	"1", ""],
          ["PVOL",	"Plateforme stable, cgt majeur tous les ans, chgt mineur mensuel",	"0,87"],
          ["ACAP",	"bonne",	"0,85", ""],
          ["PCON",	"12%/ year",	"1", ""],
          ["APEX",	"Jamais",	"1,22", ""],
          ["APEX", 	"1 à 2 applications",	"1,1", ""],
          ["APEX",	"3 à 5 applications",	"1", ""],
          ["APEX",	"Plus de 5 applications",	"0,88", ""],
          ["PLEX",	"Expérimenté",	"1",	"Default"],
          ["LTEX",	"3 ans",	"0,91", ""],
          ["TOOL",	"Outils de base du cycle de vie modérément intégrés", "1", ""],
          ["SITE",	"Même batiment - communication large bande teleconférence",	"0,86", ""],
          ["SCED",	"100% du délai calculé",	"1", ""],
          ["PBASE",	"Facteur de base pour Cocomo II Post Architecture",	"2,94", ""],
          ["LANG",	"JAVA",	"0,053",	"Default"],
          ["LANG",	"C++",	"0,029", ""],
          ["SIZE",	"Nouveau code",	"1",	"Default"]
      ]

      #export factors exeemples
      factors_exple.each_with_index do |factor, index |
        factors_exple_worksheet.add_cell(index+1, 0, factor[0]).change_horizontal_alignment('center')
        factors_exple_worksheet.add_cell(index+1, 1, factor[1])
        factors_exple_worksheet.add_cell(index+1, 2, factor[2])
        factors_exple_worksheet.add_cell(index+1, 3, factor[3])
        factors_exple_worksheet.add_cell(index+1, 4, factor[4])
        factors_exple_counter_line  += 1
      end
      factors_exple_worksheet.change_row_horizontal_alignment(5, 'justify')
      factors_exple_worksheet.change_column_width(1, 20)
      factors_exple_worksheet.change_column_width(2, 15)
      factors_exple_worksheet.change_column_width(3, 35)
      factors_exple_worksheet.change_column_width(4, 50)

      #add column border
      factors_exple_counter_line.times.each do |line|
        ["bottom", "right"].each do |symbole|
          factors_exple_worksheet[line][0].change_border(symbole.to_sym, 'thin')
          factors_exple_worksheet[line][1].change_border(symbole.to_sym, 'thin')
          factors_exple_worksheet[line][2].change_border(symbole.to_sym, 'thin')
          factors_exple_worksheet[line][3].change_border(symbole.to_sym, 'thin')
          factors_exple_worksheet[line][4].change_border(symbole.to_sym, 'thin')
        end
      end

      #export factors values exemples
      factor_values_exple.each_with_index do |factor_value, index|
        #values_worksheet.add_cell(index+1, 0, factor_value.factor_scale_prod).change_horizontal_alignment('center')
        values_exple_worksheet.add_cell(index+1, 0, factor_value[0])
        values_exple_worksheet.add_cell(index+1, 1, factor_value[1])
        values_exple_worksheet.add_cell(index+1, 2, factor_value[2]).change_horizontal_alignment('rigth')
        values_exple_worksheet.add_cell(index+1, 3, factor_value[3]).change_horizontal_alignment('center')
        values_exple_counter_line += 1
      end
      values_exple_worksheet.change_column_width(1,38)
      values_exple_worksheet.change_column_width(2,15)
      values_exple_worksheet.change_column_width(3,15)

      #add column border
      values_exple_counter_line.times.each do |line|
        ["bottom", "right"].each do |symbole|
          values_exple_worksheet[line][0].change_border(symbole.to_sym, 'thin')
          values_exple_worksheet[line][1].change_border(symbole.to_sym, 'thin')
          values_exple_worksheet[line][2].change_border(symbole.to_sym, 'thin')
          values_exple_worksheet[line][3].change_border(symbole.to_sym, 'thin')
        end
      end

    #the model factors are not nil or empty
    else
      #export factors
      ge_model_factors.each_with_index do |factor, index |
        factors_worksheet.add_cell(index+1, 0, factor.scale_prod).change_horizontal_alignment('center')
        factors_worksheet.add_cell(index+1, 1, factor.factor_type)
        factors_worksheet.add_cell(index+1, 2, factor.short_name)
        factors_worksheet.add_cell(index+1, 3, factor.long_name)
        factors_worksheet.add_cell(index+1, 4, factor.description)
        factors_counter_line += 1
      end

      factors_worksheet.change_row_horizontal_alignment(5, 'justify')
      factors_worksheet.change_column_width(1, 20)
      factors_worksheet.change_column_width(2, 15)
      factors_worksheet.change_column_width(3, 35)
      factors_worksheet.change_column_width(4, 50)

      #export factors values
      ge_factor_values.each_with_index do |factor_value, index|
        #values_worksheet.add_cell(index+1, 0, factor_value.factor_scale_prod).change_horizontal_alignment('center')
        values_worksheet.add_cell(index+1, 0, factor_value.factor_name)
        values_worksheet.add_cell(index+1, 1, factor_value.value_text)
        values_worksheet.add_cell(index+1, 2, factor_value.value_number).change_horizontal_alignment('rigth')
        values_worksheet.add_cell(index+1, 3, factor_value.default).change_horizontal_alignment('center')
        values_counter_line += 1
      end

      values_worksheet.change_column_width(1,38)
      values_worksheet.change_column_width(2,15)
      values_worksheet.change_column_width(3,15)
    end

    #add column border
    factors_counter_line.times.each do |line|
      ["bottom", "right"].each do |symbole|
        factors_worksheet[line][0].change_border(symbole.to_sym, 'thin')
        factors_worksheet[line][1].change_border(symbole.to_sym, 'thin')
        factors_worksheet[line][2].change_border(symbole.to_sym, 'thin')
        factors_worksheet[line][3].change_border(symbole.to_sym, 'thin')
        factors_worksheet[line][4].change_border(symbole.to_sym, 'thin')
      end
    end

    values_counter_line.times.each do |line|
      ["bottom", "right"].each do |symbole|
        values_worksheet[line][0].change_border(symbole.to_sym, 'thin')
        values_worksheet[line][1].change_border(symbole.to_sym, 'thin')
        values_worksheet[line][2].change_border(symbole.to_sym, 'thin')
        values_worksheet[line][3].change_border(symbole.to_sym, 'thin')
      end
    end

    send_data(workbook.stream.string, filename: "#{@ge_model.organization.name[0..4]}-#{@ge_model.name.gsub(" ", "_")}_ge_data-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end


  # Import Data with Excel files
  def import
    authorize! :manage_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:ge_model_id])

    Ge::GeFactor.destroy_all("ge_model_id = #{@ge_model.id}")

    factors_list = Array.new
    factors_values = Array.new

    sheet1_order = { :"0" => "scale_prod", :"1" => "type", :"2" => "short_name_factor", :"3" => "long_name_factor", :"4" => "description" }
    sheet2_order = { :"0" => "factor", :"1" => "text", :"2" => "value", :"3" => "default" }

    #if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
    if !params[:file].nil? && (File.extname(params[:file].original_filename).in? [".xlsx", ".Xlsx", ".xsl"])
      workbook = RubyXL::Parser.parse(params[:file].path)
      #tab1 = workbook[0].extract_data

      # We must have 2 sheets in this file
      filename = params[:file].original_filename
      worksheet1 = workbook['Factors']  # workbook[0]    # Sheet of the list of Factors
      worksheet2 = workbook['Values']    # Sheet of the factors values

      # feuille1 : worksheet1.dimension.ref.row_range
      worksheet1.each_with_index do |row, index|
        if index > 0
          row_factor = Hash.new

          row && row.cells.each do |cell|
            puts index
            val = cell && cell.value
            unless cell.nil?
              #add value to table
              key_name = sheet1_order["#{cell.column}".to_sym]
              row_factor["#{key_name}"] = val unless key_name.nil?
            end
          end

          unless row_factor.empty?
            #factors_list << row_factor

            #Create data in factors table
            #sheet1_order = { :"0" => "scale_prod", :"1" => "type", :"2" => "short_name_factor", :"3" => "long_name_factor", :"4" => "description" }
            short_name_factor = row_factor["short_name_factor"]
            factor_alias = short_name_factor.nil? ? "" : short_name_factor.gsub(/( )/, '_').downcase
            Ge::GeFactor.create(ge_model_id: @ge_model.id, short_name: short_name_factor, long_name: row_factor["long_name_factor"], factor_type: row_factor["type"],
                                     scale_prod: row_factor["scale_prod"],  data_filename: filename, description: row_factor["description"], alias: factor_alias)
          end
        end
      end

      # feuille2
      worksheet2.each_with_index do |row, index|
        if index > 0
          row_factor = Hash.new

          row && row.cells.each do |cell|
            val = cell && cell.value

            #add value to table
            key_name = sheet2_order["#{cell.column}".to_sym]
            row_factor["#{key_name}"] = val unless key_name.nil?
          end

          unless row_factor.empty?
            #factors_values << row_factor

            #Create data in factors values table
            #sheet2_order = { :"0" => "factor", :"1" => "text", :"2" => "value" }
            #FactorValues ==> :name, :alias, :value_number, :value_text, :ge_factor_id, :ge_model_id
            factor_name = row_factor["factor"]
            factor_alias = factor_name.gsub(/( )/, '_').downcase
            factors = @ge_model.ge_factors.where(alias: factor_alias)
            unless factors.nil?
              factor = factors.first
              factor_value = Ge::GeFactorValue.create(ge_model_id: @ge_model.id, ge_factor_id: factor.id, factor_alias: factor_alias, factor_scale_prod: factor.scale_prod, factor_type: factor.factor_type,
                                                      factor_name: factor_name, value_text: row_factor["text"], value_number: row_factor["value"], default: row_factor["default"])
            end
          end
        end
      end
    else
      flash[:error] =  I18n.t(:route_flag_error_4)
    end

    redirect_to ge.edit_ge_model_path(@ge_model, anchor: "tabs-2")
  end


  #Update the calculated effort when changing slider value
  def update_calculated_effort

    authorize! :execute_estimation_plan, @project

    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    @ge_input = @ge_model.ge_inputs.where(module_project_id: current_module_project.id).first_or_create
    @calculated_effort = {}

    if @ge_model.coeff_a.blank? || @ge_model.coeff_b.blank?
      # Get factors values and save them in the GeInput table
      # GeInput "values" attribute is serialize as an Array of Hash  ==> [ { :ge_factor_value_id => id, :scale_prod => val, :factor_name =>, :value => val }, {...}, ... ]
      scale_factor_sum = 0.0
      prod_factor_product = 1.0
      conversion_factor_product = 1.0

      scale_factors = params["S_factor"] || []
      prod_factors = params["P_factor"]  || []
      conversion_factors = params["C_factor"] || []

      @ge_input_values = Hash.new
      #Save Scale Factors data in GeInput table
      scale_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          scale_factor_sum += factor_value_number
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Save Prod Factors multiplier data in GeInput table
      prod_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          prod_factor_product *= factor_value_number
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Save Conversion Factors data in GeInput table
      conversion_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          conversion_factor_product *= factor_value_number
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      if scale_factor_sum == 0
        scale_factor_sum = 1
      end
    end

    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new
      ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first

      ["low", "most_likely", "high"].each do |level|

        if @ge_model.three_points_estimation?
          size = params["retained_size_#{level}"].to_f
        else
          size = params["retained_size_most_likely"].to_f
        end

        if am.pe_attribute.alias == "effort"
          #Only Xls file factors parameters will be taken in account
          if @ge_model.coeff_a.blank? || @ge_model.coeff_b.blank?
            #The effort value will be calculated as : Effort = p * (Taille * c)^s  # with: s = sum of scale factors ; p = multiply of prod factors and c = product of conversion factors
            effort = (prod_factor_product * ((size * conversion_factor_product) ** scale_factor_sum)) * @ge_model.standard_unit_coefficient.to_f
          end

          @calculated_effort["#{level}"] = effort
          tmp_prbl << effort
        end
      end

      # unless @ge_model.three_points_estimation?
      #   tmp_prbl[0] = tmp_prbl[1]
      #   tmp_prbl[2] = tmp_prbl[1]
      #   #effort probable
      #   @calculated_effort["probable"] = (tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6
      # end

    end

    respond_to do |format|
      format.html
      format.js { render layout: false, content_type: 'text/javascript' }
    end

  end


  def save_efforts
    authorize! :execute_estimation_plan, @project

    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    @ge_input = @ge_model.ge_inputs.where(module_project_id: current_module_project.id).first_or_create

    if @ge_model.coeff_a.blank? || @ge_model.coeff_b.blank?
      # Get factors values and save them in the GeInput table
      # GeInput "values" attribute is serialize as an Array of Hash  ==> [ { :ge_factor_value_id => id, :scale_prod => val, :factor_name =>, :value => val }, {...}, ... ]
      scale_factor_sum = 0.0
      prod_factor_product = 1.0
      conversion_factor_product = 1.0

      scale_factors = params["S_factor"] || []
      prod_factors = params["P_factor"]  || []
      conversion_factors = params["C_factor"] || []

      @ge_input_values = Hash.new
      #Save Scale Factors data in GeInput table
      scale_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          scale_factor_sum += factor_value_number
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Save Prod Factors multiplier data in GeInput table
      prod_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          prod_factor_product *= factor_value_number
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Save Conversion Factors data in GeInput table
      conversion_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          conversion_factor_product *= factor_value_number
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end


      if scale_factor_sum == 0
        scale_factor_sum = 1
      end
      #Update GeInput
      @formula = "#{prod_factor_product.to_f} (X * #{conversion_factor_product})^ #{scale_factor_sum.to_f}"
      @ge_input.formula = @formula
      @ge_input.scale_factor_sum = scale_factor_sum
      @ge_input.prod_factor_product = prod_factor_product
      @ge_input.values = @ge_input_values
      @ge_input.save
    end

    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first
      ["low", "most_likely", "high"].each do |level|

        if @ge_model.three_points_estimation?
          size = params["retained_size_#{level}"].to_f
        else
          size = params["retained_size_most_likely"].to_f
        end

        if am.pe_attribute.alias == "effort"
          if !@ge_model.coeff_a.blank? && !@ge_model.coeff_b.blank?
            effort = (@ge_model.coeff_a * size ** @ge_model.coeff_b) * @ge_model.standard_unit_coefficient  #Using "a" and "b"
            @ge_input.formula = "#{@ge_model.coeff_a} X ^ #{@ge_model.coeff_b}"
            @ge_input.save
          else
            #The effort value will be calculated as : Effort = p * Taille^s
            # with: s = sum of scale factors      and  p = multiply of prod factors
            effort = (prod_factor_product * ((size * conversion_factor_product) ** scale_factor_sum)) * @ge_model.standard_unit_coefficient.to_f
          end

          ev.send("string_data_#{level}")[current_component.id] = effort
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]

        elsif am.pe_attribute.alias == "retained_size"
          ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first
          ev.send("string_data_#{level}")[current_component.id] = size
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        end
      end

      unless @ge_model.three_points_estimation?
        tmp_prbl[0] = tmp_prbl[1]
        tmp_prbl[2] = tmp_prbl[1]
      end

      ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )

    end

    current_module_project.nexts.each do |n|
      ModuleProject::common_attributes(current_module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_#{level}", { current_component.id => nil } )
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_probable", { current_component.id => nil } )
        end
      end
    end

    #@current_organization.fields.each do |field|
      current_module_project.views_widgets.each do |vw|
        ViewsWidget::update_field(vw, @current_organization, current_module_project.project, current_component)
      end
    #end

    redirect_to main_app.dashboard_path(@project)
  end


  #duplicate GeModel
  def duplicate
    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    new_ge_model = @ge_model.amoeba_dup

    new_copy_number = @ge_model.copy_number.to_i+1
    new_ge_model.name = "#{@ge_model.name}(#{new_copy_number})"
    new_ge_model.copy_number = 0
    @ge_model.copy_number = new_copy_number

    #Terminate the model duplication
    new_ge_model.transaction do
      if new_ge_model.save
        @ge_model.save
        flash[:notice] = "Modèle copié avec succès"
      else
        flash[:error] = "Erreur lors de la copie du modèle"
      end
    end

    redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
  end

end
