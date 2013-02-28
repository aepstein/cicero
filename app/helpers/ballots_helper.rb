module BallotsHelper
  def candidate_label( candidate )
    link_to( candidate.name, popup_candidate_path( candidate ), target: '_blank',
      data: { toggle: 'modal', target: "#candidate-#{candidate.id}", remote: false }  )
  end
end

