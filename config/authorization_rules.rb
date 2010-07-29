authorization do
  role :admin do
    has_permission_on [ :ballots, :candidates, :elections, :petitioners, :races,
      :rolls, :sections, :users ], :to => :manage
    has_permission_on [ :ballots ], :to => :preview
  end
  role :user do
    has_permission_on [ :elections ], :to => :show do
      if_attribute :starts_at => lte { Time.zone.now }
    end
    has_permission_on [ :rolls ], :to => :show do
      if_permitted_to :show, :election
    end
    has_permission_on [ :races ], :to => :show do
      if_permitted_to :show, :roll
    end
    has_permission_on [ :candidates ], :to => :show do
      if_permitted_to :show, :race
    end
    has_permission_on [ :petitioners ], :to => :show do
      if_permitted_to :show, :candidate
    end
    has_permission_on [ :ballots ], :to => :show do
      if_attribute :user_id => is { user.id }
    end
    has_permission_on [ :users ], :to => :show do
      if_attribute :id => is { user.id }
    end
    # Voting
    has_permission_on [ :rolls ], :to => :vote do
      if_attribute :user_ids => includes { user.id }
    end
    has_permission_on [ :races ], :to => :vote do
      if_permitted_to :vote, :roll
    end
    has_permission_on [ :elections ], :to => :vote, :join_by => :and do
      if_permitted_to :vote, :rolls
      if_attribute :starts_at => lte { Time.zone.now }, :ends_at => gte { Time.zone.now }
      if_attribute :id => is_not_in { user.election_ids }
    end
    has_permission_on [ :ballots ], :to => :create, :join_by => :and do
      if_permitted_to :vote, :election
    end
    has_permission_on [ :sections ], :to => :create, :join_by => :and do
      if_permitted_to :create, :ballot
      if_permitted_to :vote, :race
    end
    has_permission_on [ :votes ], :to => :create do
      if_permitted_to :create, :section
    end
  end
end

privileges do
  privilege :manage do
    includes :create, :update, :destroy, :show, :profile
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

