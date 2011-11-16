/*Usage: 
1 create this stored procedure in your database
2 Usage in MySQL: mysql> call sp_deduct_credit_and_money ('test','test',1,0,10.00)
3 Usage in Rails: ActiveRecord::Base.connection.execute("call sp_deduct_credit_and_money('#{title}','#{content}',#{id},#{credit},#{money})") @question_controller.rb
*/
/* Drop if Exists */
DROP PROCEDURE IF EXISTS sp_answer_accept

/* Crete Stored Procedure*/
# 1 User: add credit and/or money to user table
# 2 CreditTransaction and/or MoneyTransaction
# 3 Question: mark correct answer
# 4 Answer: mark is correct answer

DELIMITER //
CREATE PROCEDURE sp_answer_accept (
	in question_id bigint,
	in answer_id bigint,
	in user_id bigint,
	in winner_id bigint,
	in reputation_for_asker int,
	in reputation_for_winner int,
	in credit_for_winner DECIMAL(8,2),
	in transaction_from_system_for_winner int,
	in transaction_from_system_for_asker int)
BEGIN
IF credit_for_winner = 0.00 THEN
	START TRANSACTION;
	#give reputation to winner
	INSERT INTO reputation_transactions (question_id, answer_id, receiver_id, reputation, trade_type) 
		 VALUES (question_id, answer_id, winner_id, reputation_for_winner, transaction_from_system_for_winner);
	UPDATE users SET reputation = reputation + reputation_for_winner WHERE id = winner_id;
	
	INSERT INTO reputation_transactions (question_id, answer_id, receiver_id, reputation, trade_type) 
		 VALUES (question_id, answer_id, winner_id, reputation_for_asker, transaction_from_system_for_asker);
	UPDATE users SET reputation = reputation + reputation_for_asker WHERE id = user_id;
	
	UPDATE questions SET correct_answer_id = answer_id WHERE id = question_id;
	UPDATE answers SET is_correct = true WHERE id = answer_id;
	COMMIT;
ELSE IF credit_for_winner > 0.00 THEN
    START TRANSACTION;
    INSERT INTO reputation_transactions (question_id, answer_id, receiver_id, reputation, trade_type) 
    	 VALUES (question_id, answer_id, winner_id, reputation_for_winner, transaction_from_system_for_winner);
    
	INSERT INTO credit_transactions (question_id, answer_id, receiver_id, credit_for_winner, trade_type) 
	 	 VALUES (question_id, answer_id, winner_id, credit_for_winner, transaction_from_system_for_winner);
	UPDATE users SET credit = credit + credit_for_winner, reputation = reputation + reputation_for_winner WHERE id = winner_id;

    INSERT INTO reputation_transactions (question_id, answer_id, receiver_id, reputation, trade_type) 
    	 VALUES (question_id, answer_id, winner_id, reputation_for_asker, transaction_from_system_for_asker);
    UPDATE users SET reputation = reputation + reputation_for_asker WHERE id = user_id;

    UPDATE questions SET correct_answer_id = answer_id WHERE id = question_id;
    UPDATE answers SET is_correct = true WHERE id = answer_id;
    COMMIT;
end if;
end if;
END