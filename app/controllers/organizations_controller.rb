#encoding: utf-8
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
#    ===================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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

class OrganizationsController < ApplicationController
  load_resource
  require 'axlsx'
  require 'rubygems'
  require 'roo'
  include Roo


  def new
    set_page_title 'Organizations'
    @organization = Organization.new
  end

  def edit
    #No authorize required since everyone can edit

    set_page_title 'Organizations'
    @organization = Organization.find(params[:id])

    set_breadcrumbs "Dashboard" => "/dashboard", "Organizations" => "/organizationals_params", @organization => ""

    @attributes = PeAttribute.defined.all
    @attribute_settings = AttributeOrganization.all(:conditions => {:organization_id => @organization.id})

    @complexities = @organization.organization_uow_complexities
    @projects = @organization.projects.reject { |i| !i.is_childless? }

    @wbs_activities = @organization.wbs_activities

    @technologies = @organization.organization_technologies
    @size_units = SizeUnit.all
    @size_unit_types = @organization.size_unit_types

    @factors = Factor.order("factor_type")

    @ot = @organization.organization_technologies.first
    @unitofworks = @organization.unit_of_works
    @default_subcontractors = @organization.subcontractors.where('alias IN (?)', %w(undefined internal subcontracted))

    @users = @organization.users
    @groups = @organization.groups
    @fields = @organization.fields

    @organization_profiles = @organization.organization_profiles

    #Get the Master defined groups and the organization's group
    #@organization_group = (Group.defined.all + @organization.groups.all).flatten
    @organization_group = @organization.groups
    @guw_models = @organization.guw_models
  end

  def refresh_value_elements
    @size_unit = SizeUnit.find(params[:size_unit_id])
    @technologies = OrganizationTechnology.all
  end

  def create
    @organization = Organization.new(params[:organization])

    # Add current_user to the organization
    @organization.users << current_user

    #A la sauvegarde, on crée des sous traitants
    if @organization.save

      #Create the organization's default subcontractor
      subcontractors = [
          ['Undefined', '_undefined', "Haven't a clue if it will be subcontracted or made internally"],
          ['Internal', '_internal', 'Will be made internally'],
          ['Subcontracted', '_subcontracted', "Will be subcontracted (but don't know the subcontractor yet)"]
      ]
      subcontractors.each do |i|
        @organization.subcontractors.create(:name => i[0], :alias => i[1], :description => i[2], :state => 'defined')
      end

      #Create default the size unit type's
      size_unit_types = [
          ['New', 'new', ""],
          ['Modified', 'new', ""],
          ['Reused', 'new', ""],
      ]
      size_unit_types.each do |i|
        sut = SizeUnitType.create(:name => i[0],
                                  :alias => i[1],
                                  :description => i[2],
                                  :organization_id => @organization.id)

        @organization.organization_technologies.each do |ot|
          SizeUnit.all.each do |su|
            TechnologySizeType.create(organization_id: sut.organization_id,
                                      organization_technology_id: ot.id,
                                      size_unit_id: su.id,
                                      size_unit_type_id: sut.id,
                                      value: 1)
          end
        end
      end

      uow = [
          ['Données', 'data', "Création, modification, suppression, duplication de composants d'une base de données (tables, fichiers). Une UO doit être comptée pour chaque entité métier. Seules les entités métier sont comptabilisées."],
          ['Traitement', 'traitement', 'Création, modification, suppression, duplication de composants de visualisation, gestion de données, activation de fonctionnalités avec une interface de type Caractère (terminal passif).'],
          ['Batch', 'batch', "Création, modification, suppression, duplication de composants d'extraction ou de MAJ de données d'une source de données persistante. Par convention, cette UO ne couvre pas les interfaces. Cette UO couvre le nettoyage et la purge des tables."],
          ['Interfaces', 'interface', "Création, modification, suppression, duplication de composants d'interface de type : Médiation, Conversion, Transcodification, Transformation (les transformations sont implémentées en langage de programmation). Les 'Historisation avec clés techniques générée' sont à comptabiliser en 'Règle de gestion'"]
      ]
      uow.each do |i|
        @organization.unit_of_works.create(:name => i[0], :alias => i[1], :description => i[2], :state => 'defined')
      end

      #A la création de l'organixation, on crée les complexités de facteurs à partir des defined ( les defined ont organization_id => nil)
      OrganizationUowComplexity.where(organization_id: nil).each do |o|
        ouc = OrganizationUowComplexity.new(name: o.name , organization_id: @organization.id, description: o.description, value: o.value, factor_id: o.factor_id, is_default: o.is_default, :state => 'defined')
        ouc.save(validate: false)
      end

      #Et la, on crée les complexités des unités d'oeuvres par défaut
      levels = [
          ['Simple', 'simple', "Simple", 1, "defined"],
          ['Moyen', 'moyen', "Moyen", 2, "defined"],
          ['Complexe', 'complexe', "Complexe", 4, "defined"]
      ]
      levels.each do |i|
        @organization.unit_of_works.each do |uow|
          ouc = OrganizationUowComplexity.new(:name => i[0], :alias => i[1],
                                              :description => i[2], :state => i[4], :unit_of_work_id => uow.id,
                                              :organization_id => @organization.id)
          ouc.save(validate: false)

          @organization.size_unit_types.each do |sut|
            SizeUnitTypeComplexity.create(size_unit_type_id: sut.id, organization_uow_complexity_id: ouc.id, value: i[3])
          end
        end
      end

      #A la sauvegarde, on copies des technologies
      Technology.all.each do |technology|
        ot = OrganizationTechnology.new(name: technology.name, alias: technology.name,  description: technology.description, organization_id: @organization.id)
        ot.save(validate: false)
      end

      # Add MasterData Profiles to Organization
      Profile.all.each do |profile|
        op = OrganizationProfile.new(organization_id: @organization.id, name: profile.name, description: profile.description, cost_per_hour: profile.cost_per_hour)
        op.save
      end

      # Add some Estimations statuses in organization
      estimation_statuses = [
          ['0', 'preliminary', "Préliminaire", "999999", "Statut initial lors de la création de l'estimation"],
          ['1', 'in_progress', "En cours", "3a87ad", "En cours de modification"],
          ['2', 'in_review', "Relecture", "f89406", "En relecture"],
          ['3', 'checkpoint', "Contrôle", "b94a48", "En phase de contrôle"],
          ['4', 'released', "Confirmé", "468847", "Phase finale d'une estimation qui arrive à terme et qui sera retenue comme une version majeure"],
          ['5', 'rejected', "Rejeté", "333333", "L'estimation dans ce statut est rejetée et ne sera pas poursuivi"]
      ]
      estimation_statuses.each do |i|
        status = EstimationStatus.create(organization_id: @organization.id, status_number: i[0], status_alias: i[1], name: i[2], status_color: i[3], description: i[4])
      end

      redirect_to redirect_apply(edit_organization_path(@organization)), notice: "#{I18n.t (:notice_organization_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:id])
    if @organization.update_attributes(params[:organization])

      OrganizationUowComplexity.where(organization_id: @organization.id).each do |ouc|
        @organization.size_unit_types.each do |sut|
          sutc = SizeUnitTypeComplexity.where(size_unit_type_id: sut.id, organization_uow_complexity_id: ouc.id).first
          if sutc.nil?
            SizeUnitTypeComplexity.create(size_unit_type_id: sut.id, organization_uow_complexity_id: ouc.id)
          end
        end
      end

      flash[:notice] = I18n.t (:notice_organization_successful_updated)
      redirect_to redirect_apply(edit_organization_path(@organization), nil, '/organizationals_params')
    else
      @attributes = PeAttribute.defined.all
      @attribute_settings = AttributeOrganization.all(:conditions => {:organization_id => @organization.id})
      @complexities = @organization.organization_uow_complexities
      @ot = @organization.organization_technologies.first
      @unitofworks = @organization.unit_of_works
      @default_subcontractors = @organization.subcontractors.where('alias IN (?)', %w(undefined internal subcontracted))
      @factors = Factor.order("factor_type")
      @technologies = OrganizationTechnology.all
      @size_unit_types = SizeUnitType.all

      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, Organization
    @organization = Organization.find(params[:id])

    # Before destroying, we should check if the organization is used by one or more projects/estimations before to be able to delete it.
    if @organization.projects.empty? || @organization.projects.nil?
      @organization.destroy
      flash[:notice] = I18n.t(:notice_organization_successful_deleted)
    else
      flash[:warning] = I18n.t(:warning_organization_cannot_be_deleted, value: @organization.name)
    end

    redirect_to '/organizationals_params'
  end

  def organizationals_params
    set_page_title 'Organizational Parameters'
    if can? :manage, :all
      @organizations = Organization.all
    else
      @organizations = current_user.organizations
    end

    @size_units = SizeUnit.all
    @factors = Factor.order("factor_type")
  end

  def set_technology_size_type_abacus
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:organization])
    @technologies = @organization.organization_technologies
    @size_unit_types = @organization.size_unit_types
    @size_units = SizeUnit.all

    @technologies.each do |technology|
      @size_unit_types.each do |sut|
        @size_units.each do |size_unit|

          #size_unit = params[:size_unit]["#{su.id}"].to_i

          value = params[:abacus]["#{size_unit.id}"]["#{technology.id}"]["#{sut.id}"].to_f

          unless value.nil?
            t = TechnologySizeType.where( organization_id: @organization.id,
                                          organization_technology_id: technology.id,
                                          size_unit_id: size_unit,
                                          size_unit_type_id: sut.id).first

            if t.nil?
              TechnologySizeType.create(organization_id: @organization.id,
                                        organization_technology_id: technology.id,
                                        size_unit_id: size_unit,
                                        size_unit_type_id: sut.id,
                                        value: value)
            else
              t.update_attributes(value: value)
            end
          end
        end
      end
    end

    redirect_to edit_organization_path(@organization, :anchor => 'tabs-abacus-sut')
  end

  def set_technology_size_unit_abacus
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:organization])
    @technologies = @organization.organization_technologies
    @size_units = SizeUnit.all

    @technologies.each do |technology|
      @size_units.each do |size_unit|
        value = params[:technology_size_units_abacus]["#{size_unit.id}"]["#{technology.id}"].to_f

        unless value.nil?
          t = TechnologySizeUnit.where( organization_id: @organization.id,
                                        organization_technology_id: technology.id,
                                        size_unit_id: size_unit.id).first

          if t.nil?
            TechnologySizeUnit.create(organization_id: @organization.id,
                                      organization_technology_id: technology.id,
                                      size_unit_id: size_unit.id,
                                      value: value)
          else
            t.update_attributes(value: value)
          end
        end
      end
    end

    redirect_to edit_organization_path(@organization, :anchor => 'tabs-abacus-tsu')

  end

  def set_abacus
    authorize! :edit_organizations, Organization

    @ot = OrganizationTechnology.find_by_id(params[:technology])
    @complexities = @ot.organization.organization_uow_complexities
    @unitofworks = @ot.unit_of_works

    @unitofworks.each do |uow|
      @complexities.each do |c|
        a = AbacusOrganization.find_or_create_by_unit_of_work_id_and_organization_uow_complexity_id_and_organization_technology_id_and_organization_id(uow.id, c.id, @ot.id, params[:id])
        begin
          a.update_attribute(:value, params['abacus']["#{uow.id}"]["#{c.id}"])
        rescue
          # :()
        end
      end
    end
    redirect_to redirect_apply(edit_organization_path(@ot.organization_id, :anchor => 'tabs-abacus-tsu'), nil, '/organizationals_params')
  end

  def set_technology_uow_synthesis
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:organization])
    params[:abacus].each do |sut|
      sut.last.each do |ot|
        ot.last.each do |uow|
          uow.last.each do |cplx|
            sutc = SizeUnitTypeComplexity.where(size_unit_type_id: sut.first.to_i,
                                                organization_uow_complexity_id: cplx.first.to_i).first
            sutc.value = cplx.last
            sutc.save
          end
        end
      end
    end

    #array << technology.id
    #
    #unit =
    #unit.organization_technology_ids = array
    #unit.save

    redirect_to redirect_apply(edit_organization_path(@organization, :anchor => 'tabs-synthesis-uow-techno'), nil, '/organizationals_params')
  end

  def import_abacus
    authorize! :edit_organizations, Organization
    @organization = Organization.find(params[:id])

    file = params[:file]

    case File.extname(file.original_filename)
      when ".ods"
        workbook = Roo::Spreadsheet.open(file.path, extension: :ods)
      when ".xls"
        workbook = Roo::Spreadsheet.open(file.path, extension: :xls)
      when ".xlsx"
        workbook = Roo::Spreadsheet.open(file.path, extension: :xlsx)
      when ".xlsm"
        workbook = Roo::Spreadsheet.open(file.path, extension: :xlsx)
    end

    workbook.sheets.each_with_index do |worksheet, k|
      #if sheet name blank, we use sheetN as default name
      name = worksheet
      if name != 'ReadMe' #The ReadMe sheet is only for guidance and don't have to be proceed

        @ot = OrganizationTechnology.find_or_create_by_name_and_alias_and_organization_id(:name => name,
                                                                                          :alias => name,
                                                                                          :organization_id => @organization.id)

        workbook.default_sheet=workbook.sheets[k]
        workbook.each_with_index do |row, i|
          row.each_with_index do |cell, j|
            unless row.nil?
              unless workbook.cell(1,j+1) == "Abacus" or workbook.cell(i+1,1) == "Abacus"
                if can? :manage, Organization
                  @ouc = OrganizationUowComplexity.find_or_create_by_name_and_organization_id(:name => workbook.cell(1,j+1), :organization_id => @organization.id)
                end

                if can? :manage, Organization
                  @uow = UnitOfWork.find_or_create_by_name_and_alias_and_organization_id(:name => workbook.cell(i+1,1), :alias => workbook.cell(i+1,1), :organization_id => @organization.id)
                  unless @uow.organization_technologies.map(&:id).include?(@ot.id)
                    @uow.organization_technologies << @ot
                  end
                  @uow.save
                end

                ao = AbacusOrganization.find_by_unit_of_work_id_and_organization_uow_complexity_id_and_organization_technology_id_and_organization_id(
                    @uow.id,
                    @ouc.id,
                    @ot.id,
                    @organization.id
                )

                if ao.nil?
                  if can? :manage, Organization
                    AbacusOrganization.create(
                        :unit_of_work_id => @uow.id,
                        :organization_uow_complexity_id => @ouc.id,
                        :organization_technology_id => @ot.id,
                        :organization_id => @organization.id,
                        :value => workbook.cell(i+1, j+1))
                  end
                else
                  ao.update_attribute(:value, workbook.cell(i+1, j+1))
                end
              end
            end
          end
        end
      end
    end

    redirect_to redirect_apply(edit_organization_path(@organization.id), nil, '/organizationals_params')
  end

  def export_abacus
    #No authorize required since everyone can edit

    @organization = Organization.find(params[:id])
    p=Axlsx::Package.new
    wb=p.workbook
    @organization.organization_technologies.each_with_index do |ot|
      wb.add_worksheet(:name => ot.name) do |sheet|
        style_title = sheet.styles.add_style(:bg_color => 'B0E0E6', :sz => 14, :b => true, :alignment => {:horizontal => :center})
        style_title2 = sheet.styles.add_style(:sz => 14, :b => true, :alignment => {:horizontal => :center})
        style_title_red = sheet.styles.add_style(:bg_color => 'B0E0E6', :fg_color => 'FF0000', :sz => 14, :b => true, :i => true, :alignment => {:horizontal => :center})
        style_title_orange = sheet.styles.add_style(:bg_color => 'B0E0E6', :fg_color => 'FF8C00', :sz => 14, :b => true, :i => true, :alignment => {:horizontal => :center})
        style_title_right = sheet.styles.add_style(:bg_color => 'E6E6E6', :sz => 14, :b => true, :alignment => {:horizontal => :right})
        style_title_right_red = sheet.styles.add_style(:bg_color => 'E6E6E6', :fg_color => 'FF8C00', :sz => 14, :b => true, :i => true, :alignment => {:horizontal => :right})
        style_title_right_orange = sheet.styles.add_style(:bg_color => 'E6E6E6', :fg_color => 'FF8C00', :sz => 14, :b => true, :i => true, :alignment => {:horizontal => :right})
        style_data = sheet.styles.add_style(:sz => 12, :alignment => {:horizontal => :center}, :locked => false)
        style_date = sheet.styles.add_style(:format_code => 'YYYY-MM-DD HH:MM:SS')
        head = ['Abacus']
        head_style = [style_title2]
        @organization.organization_uow_complexities.each_with_index do |comp|
          head.push(comp.name)
          if comp.state == 'retired'
            head_style.push(style_title_red)
          elsif comp.state == 'draft'
            head_style.push(style_title_orange)
          else
            head_style.push(style_title)
          end
        end
        row=sheet.add_row(head, :style => head_style)
        ot.unit_of_works.each_with_index do |uow|
          uow_row = []
          if uow.state == 'retired'
            uow_row_style=[style_title_right_red]
          elsif uow.state == 'draft'
            uow_row_style=[style_title_right_orange]
          else
            uow_row_style=[style_title_right]
          end
          uow_row = [uow.name]

          @organization.organization_uow_complexities.each_with_index do |comp2, i|
            if AbacusOrganization.where(:unit_of_work_id => uow.id, :organization_uow_complexity_id => comp2.id, :organization_technology_id => ot.id, :organization_id => @organization.id).first.nil?
              data = ''
            else
              data = AbacusOrganization.where(:unit_of_work_id => uow.id,
                                              :organization_uow_complexity_id => comp2.id,
                                              :organization_technology_id => ot.id, :organization_id => @organization.id).first.value
            end
            uow_row_style.push(style_data)
            uow_row.push(data)
          end
          row=sheet.add_row(uow_row, :style => uow_row_style)
        end
        sheet.sheet_protection.delete_rows = true
        sheet.sheet_protection.delete_columns = true
        sheet.sheet_protection.format_cells = true
        sheet.sheet_protection.insert_columns = false
        sheet.sheet_protection.insert_rows = false
        sheet.sheet_protection.select_locked_cells = false
        sheet.sheet_protection.select_unlocked_cells = false
        sheet.sheet_protection.objects = false
        sheet.sheet_protection.sheet = true
      end
    end
    wb.add_worksheet(:name => 'ReadMe') do |sheet|
      style_title2 = sheet.styles.add_style(:sz => 14, :b => true, :alignment => {:horizontal => :center})
      style_title_right = sheet.styles.add_style(:bg_color => 'E6E6E6', :sz => 13, :b => true, :alignment => {:horizontal => :right})
      style_date = sheet.styles.add_style(:format_code => 'YYYY-MM-DD HH:MM:SS', :alignment => {:horizontal => :left})
      style_text = sheet.styles.add_style(:alignment => {:wrapText => :true})
      style_field = sheet.styles.add_style(:bg_color => 'F5F5F5', :sz => 12, :b => true)

      sheet.add_row(['This File is an export of a ProjEstimate abacus'], :style => style_title2)
      sheet.merge_cells 'A1:F1'
      sheet.add_row(['Organization: ', "#{@organization.name} (#{@organization.id})", @organization.description], :style => [style_title_right, 0, style_text])
      sheet.add_row(['Date: ', Time.now], :style => [style_title_right, style_date])
      sheet.add_row([' '])
      sheet.merge_cells 'A5:F5'
      sheet.add_row(['There is one sheet by technology. Each sheet is organized with the complexity by column and the Unit Of work by row.'])
      sheet.merge_cells 'A6:F6'
      sheet.add_row(['For the complexity and the Unit Of Work state, we are using the following color code : Red=Retired, Orange=Draft).'])
      sheet.merge_cells 'A7:F7'
      sheet.add_row(['In order to allow this abacus to be re-imported into ProjEstimate and to prevent users from accidentally changing the structure of the sheets, workbooks have been protected.'])
      sheet.merge_cells 'A8:F8'
      sheet.add_row(['Advanced users can remove the protection (there is no password). For further information you can have a look on the ProjEstimate Help.'])
      row=sheet.add_row(['For ProjEstimate Help, Click to go'])
      sheet.add_hyperlink :location => 'http://forge.estimancy.com/projects/pe/wiki/Organizations', :ref => "A#{row.index+1}"
      sheet.add_row([' '])
      sheet.add_row([' '])
      sheet.add_row(['Technologies'], :style => [style_title_right])
      sheet.add_row(['Alias', 'Name', 'Description', 'State', 'Productivity Ratio'], :style => style_field)
      @organization.organization_technologies.each_with_index do |ot|
        sheet.add_row([ot.alias, ot.name, ot.description, ot.state, ot.productivity_ratio], :style => [0, 0, style_text])
      end
      sheet.add_row([' '])
      sheet.add_row(['Complexities'], :style => [style_title_right])
      sheet.add_row(['Display Order', 'Name', 'Description', 'State'], :style => style_field)
      @organization.organization_uow_complexities.each_with_index do |comp|
        sheet.add_row([comp.display_order, comp.name, comp.description, comp.state], :style => [0, 0, style_text])
      end
      sheet.add_row([' '])
      sheet.add_row(['Units OF Works'], :style => [style_title_right])
      sheet.add_row(['Alias', 'Name', 'Description', 'State'], :style => style_field)
      @organization.unit_of_works.each_with_index do |uow|
        sheet.add_row([uow.alias, uow.name, uow.description, uow.state], :style => [0, 0, style_text])
      end
      sheet.column_widths 20, 32, 80, 10, 18
    end
    send_data p.to_stream.read, :filename => @organization.name+'.xlsx'
  end


  # Duplicate the organization
  def duplicate_organization
    authorize! :create_organizations, Organization
    original_organization = Organization.find(params[:organization_id])
    new_organization = original_organization.amoeba_dup
    if new_organization.save
      ###original_organization_technologies = original_organization.organization_technologies
      flash[:notice] = I18n.t(:organization_successfully_copied)
    else
      flash[:error] = "#{ I18n.t(:errors_when_copying_organization)} : #{new_organization.errors.messages.keys.join(', ')}"
    end
    redirect_to organizationals_params_path
  end

  def show
  end

  def export
    @organization = Organization.find(params[:organization_id])

    p = Axlsx::Package.new

    wb = p.workbook

    @organization.groups.each_with_index do |group|
      wb.add_worksheet(:name => group.name) do |sheet|

        group.users.each_with_index do |user|
          sheet.add_row([user.name])
        end
      end

      @organization.projects.each_with_index do |project|
        project.users.each_with_index do |user|
          sheet.add_row([user.name])
        end
      end

    end

    send_data p.to_stream.read, :filename => @organization.name+'.xlsx'
  end

end
