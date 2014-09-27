authorization do
  role :admin do
    has_permission_on [ :candidates, :elections, :petitioners, :races,
      :rolls, :sections, :users ], to: [ :manage, :show ]
    has_permission_on [ :ballots ], to: [ :preview, :destroy, :show ]
    has_permission_on [ :users ], to: :tabulate
    has_permission_on [ :elections ], to: :tabulate do
      if_attribute results_available_at: lt { Time.zone.now }
    end
  end
  role :user do
    has_permission_on [ :elections ], to: :show do
      if_attribute starts_at: lte { Time.zone.now },
        confidential: is_not { true }
    end
    has_permission_on [ :elections ], to: :show do
      if_attribute starts_at: lte { Time.zone.now },
        rolls: { id: is_in { user.roll_ids } }
    end
    has_permission_on [ :races ], to: :tabulate do
      if_permitted_to :tabulate, :election
    end
    has_permission_on [ :rolls ], to: :show do
      if_permitted_to :show, :election
    end
    has_permission_on [ :races ], to: :show do
      if_permitted_to :show, :roll
    end
    has_permission_on [ :candidates ], to: :show do
      if_permitted_to :show, :race
    end
    has_permission_on [ :petitioners ], to: :show do
      if_attribute user_id: is { user.id }
    end
    has_permission_on [ :ballots ], to: :show do
      if_attribute user_id: is { user.id }
    end
    has_permission_on [ :users ], to: [:show, :tabulate] do
      if_attribute id: is { user.id }
    end
    # Voting
    has_permission_on [ :elections ], to: :vote, join_by: :and do
      if_attribute id: is_in { user.elections.allowed.map(&:id) }
    end
    has_permission_on [ :ballots ], to: :create, join_by: :and do
      if_permitted_to :vote, :election
      if_attribute user_id: is { user.id }
    end
    has_permission_on [ :ballots ], to: :show do
      if_permitted_to :tabulate, :user
    end
  end
end

privileges do
  privilege :manage do
    includes :create, :update, :destroy, :profile, :index
  end
  privilege :create do
    includes :new, :confirm
  end
  privilege :update do
    includes :edit
  end
  privilege :show do
    includes :index
  end
end

