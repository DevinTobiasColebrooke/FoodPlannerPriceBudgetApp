class LegalDocumentsController < ApplicationController
  def show
    @document = LegalDocument.find(params[:id])
  end
end
