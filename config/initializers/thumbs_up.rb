module ThumbsUp
  module ActsAsVoteable
    module InstanceMethods

      def trivalent_voted_by?(voter)
        Vote.select("vote").where(
          :voteable_id => self.id,
          :voteable_type => self.class.name,
          :voter_type => voter.class.name,
          :voter_id => voter.id
        ).limit(1).map(&:vote).first
      end

    end
  end
end
