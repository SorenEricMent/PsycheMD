% DSM-5 + SCID-5 Formalization in Prolog

:- style_check(-discontiguous). %% Each question has different set of clauses, no need for clustering.

%% General Helper function
    
least_x_yes(X, List, Index) :-
    count_yes(List, Index, Count),
    Count >= X.

% Base case: an empty list has zero yes responses.
count_yes([], _, 0).

% When the current ID is answered 'yes', increment count.
count_yes([Id|Rest], Index, Count) :-
    question_answer(Id, yes, Index),
    count_yes(Rest, Index, CountRest),
    Count is CountRest + 1.

% Otherwise, if the answer is not 'yes' (for instance, 'no'), skip incrementing.
count_yes([Id|Rest], Index, Count) :-
    question_answer(Id, no, Index),
    count_yes(Rest, Index, Count).

% Base case: empty list is trivially satisfied.
all_ids_have_answers([], _).

% Recursive case: for the head of the list, check if there's a matching question_answer clause;
% then proceed to the rest of the list.
all_ids_have_answers([Id | Rest], Index) :-
    question_answer(Id, _, Index),
    all_ids_have_answers(Rest, Index).

%% State Database
%%% Basic management if a fact is true.
%%%% Store by query format question_answer(<identifier>, Answer, No. of Record
%%%% (set of questions can be asked multiple times)).

:- dynamic question_answer/3.

%%%% A set's conclusive criteria is met.
:- dynamic qset_satisfy/1.

%%%% Because a set of question can be asked multiple times, we need something to keep track of the times this set of question is being asked.
:- dynamic current_index/2.

%%%% A conclusive question can potentially demand a new trial on a set of questions.
:- dynamic demand/2.
%%%% Internal state managed by answering that question, so that we move to a new set of questions when needed.
:- dynamic once_trigger/1.

%%% Format: demand(<disease>, <demand question id>).
%%% Demand can be negated by once_trigger, since we cannot retract a demand established by conditions.
	   
%%% Conclusions for future extension
:- dynamic symptom_potential/1.
:- dynamic symptom_confident/1.

/**
 *
 * Initialize or reset the current index for the given Question to 1.
 * If there's already a stored index, we remove it first.
 */
init_current_indexs([]).
init_current_indexs([Question|List]) :-
    init_current_index(Question),
    init_current_indexs(List).
init_current_index(Question) :-
%    retractall(current_index(Question, _)),
    asserta(current_index(Question, 1)).

answer_question(Question, Answer) :-
    retract(current_index(Question, I)),
    NextI = I + 1,
    assertz(current_index(Question, NextI)),
    assertz(question_answer(Question, Answer, NextI)),
    assertz(once_trigger(Question)).

/**
 * get_new_question(+Disease, +Index, -Question)
 *
 * Finds an unanswered question (ID) for the given Disease at the
 * specified Index. The logic:
 *
 *   1) If a main question is answered at this Index,
 *      return one of its follow-up questions that is NOT answered yet.
*    2) Ask for the question explicitly demanded by some conditions.
 *   3) Otherwise, return a primary question that is not yet answered.
 *   4) Otherwise, return a non-conclusive question that is not yet answered.
 */

get_new_question(Disease, Question) :-
    /* 1) Check if there's a main question for Disease that is answered at
          this Index, and pick a follow-up that is still unanswered. */
    question(MainQ, Disease, _AnsType, _Prompt, _Criteria, FollowUps),
    question_answer(MainQ, _MainAnswer, Index),
    member(Question, FollowUps),
    \+ question_answer(Question, _AnyAnswer, Index).

get_new_question(Disease, Question) :-
    \+ assertz(once_trigger(Question)),
    demand(Disease, Question).

get_new_question(Disease, Question) :-
    /* 2) If that fails, pick a primary question not yet answered. */
    question(Question, Disease, _AnsType, _Prompt, _Criteria, _FollowUps),
    \+ conclusive_question(Question, _, _),
    primary(Question),
    \+ question_answer(Question, _AnyAnswer, _), !.

get_new_question(Disease, Question) :-
    /* 3) Otherwise, pick any non-conclusive question not yet answered. */
    question(Question, Disease, _AnsType, _Prompt, _Criteria, _FollowUps),
    \+ conclusive_question(Question, _, _),
    \+ question_answer(Question, _AnyAnswer, _), !.



%% Disorder database
%%% Indicates the capability of this prolog database.
%%%% Format:
%%%% disorder(<disorder_atom>).
%%%% known_unimplemented(<disorder_atom>). (For known possible disease but not yet implemented in the db).
disorder_cat(anxiety_disorder).

disorder(anxiety_disorder, general_anxiety_disorder).
disorder(anxiety_disorder, social_anxiety_disorder).
disorder(anxiety_disorder, agoraphobia).

%% Question Database
%%%% Format: question(<identifier>, <disorder_atom>, AnswerType:"Boolean"|..., "<criteria>", "Example Inquiry", [Follow up questions]).
%%%% Backend must exhaust all subquestions first!!
%%%% Follow up questions must be answered after accordingly.
%%%% Format: subquestion(<parent_identifier>, <identifier>, AnswerType:"Boolean"|..., "<condition>", "<criteria>").
%%%% Format: follow_up(<parent_identifier>, <identifier>, AnswerType:"Boolean"|..., "<Question>")
%%%% Format: primary(<identifier>) % The first question in a set to ask.
primary(f1).
question(f1, anxiety_disorder, "Boolean",
	 "Have you ever had an intense rush of anxiety, or what someone might call a \"panic attack,\" when you suddenly felt very frightened or anxious or suddenly developed a lot of physical symptoms? (Tell me about that.) When was the last bad one? What was it like? How did it begin?"
	 ,"[Panic Attack] A panic attack is an abrupt surge of intense fear or intense discomfort that reaches a peak within minute, and during which time four (or more) of the following symptoms occur(Note: The abrupt surge can occur from a calm state or an anxious state.) (Note: the following symptom is encoded in subquestions, don't worry about them, they will pop in next get question query):
", [f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14]).
subquestion(f1, f1_s1, "Boolean", "IF UNCLEAR", "Did the symptoms come on suddenly?").
subquestion(f1, f1_s2, "Boolean", "IF YES", "How long did it take from when it began to when it got really bad? (Did it happen within a few minutes?)").

question(f2, anxiety_disorder, "Boolean",
	 "During that attack...
...did your heart race, pound, or skip?", "Palpitations, pounding heart, or accelerated heart rate.", []).
question(f3, anxiety_disorder, "Boolean",
	 "...did you sweat?", "2. Sweating.", []).
question(f4, anxiety_disorder, "Boolean",
	 "...did you tremble or shake?", "Trembling or shaking.", []).
question(f5, anxiety_disorder, "Boolean",
	 "...were you short of breath? (Have trouble catching your breath? Feel like you were being smothered?)", "Sensations of shortness of breath or smothering.", []).
question(f6, anxiety_disorder, "Boolean",
	 "...did you feel as if you were choking?", "Feelings of choking.", []).
question(f7, anxiety_disorder, "Boolean",
	 "...did you have chest pain or pressure?", "Chest pain or discomfort.", []).
question(f8, anxiety_disorder, "Boolean",
	 "...did you have nausea or upset stomach or the feeling that you were going to have diarrhea?", "Nausea or abdominal distress.", []).
question(f9, anxiety_disorder, "Boolean",
	 "...did you feel dizzy, unsteady, or like you might pass out?", "Feeling dizzy, unsteady, light-headed, or faint.", []).
question(f10, anxiety_disorder, "Boolean",
	 "...did you have flushes, hot flashes, or chills?", "Chills or heat sensations.", []).
question(f11, anxiety_disorder, "Boolean",
	 "...did you have tingling or numbness in parts of your body?", "Paresthesias (numbness or tingling sensations).", []).
question(f12, anxiety_disorder, "Boolean",
	 "...did you have the feeling that you were detached from your body or mind, that time was moving slowly, or that you were an outside observer of your own thoughts or movements?
IF NO: How about feeling that everything around you was unreal or that you were in a dream?", "Derealization (feelings of unreality) or depersonalization (being detached from oneself).", []).
question(f13, anxiety_disorder, "Boolean",
	 "...were you afraid you were going crazy or might lose control?
", "Fear of losing control or “going crazy.”", []).
question(f14, anxiety_disorder, "Boolean",
	 "...were you afraid that you were dying?", "Fear of dying.", []).


conclusive_question(f15, "Besides the one you just described, have you had any other attacks which had even more of the symptoms that I just asked you about", f1_f15).

qset_satisfy(f1_f15) :- least_x_yes(4, [f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14], _).

demand(anxiety_disorder, f16) :- \+ once_trigger(f16),
				 qset_satisfy(f1_f15).
				 
demand(anxiety_disorder, f1) :- \+ demand(anxiety_disorder, f16),
				current_index(f15, Index),
				question_answer(f15, yes, Index).

demand(agoraphobia, f23) :- \+ once_trigger(f23),
			    current_index(f11, Index),
			    question_answer(f11, no, Index).

demand(agoraphobia, f23) :- \+ once_trigger(f23),
			    \+ qset_satisfy(f1_f15),
			    current_index(f15, Index),
			    question_answer(f15, no, Index).

demand(anxiety_disorder, f15) :-
    current_index(f1, Index),
    all_ids_have_answers([f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12 ,f13, f14], Index),
    \+ demand(anxiety_disorder, f16).

question(f16, anxiety_disorder, "Boolean", "", "", []).
question(f17, anxiety_disorder, "Boolean", "", "", []).
question(f18, anxiety_disorder, "Boolean", "", "", []).
question(f19, anxiety_disorder, "Boolean", "", "", []).
question(f20, anxiety_disorder, "Boolean", "", "", []).
question(f21, anxiety_disorder, "Boolean", "", "", []).
question(f22, anxiety_disorder, "Boolean", "", "", []).
question(f23, anxiety_disorder, "Boolean", "", "", []).
question(f24, anxiety_disorder, "Boolean", "", "", []).
question(f25, anxiety_disorder, "Boolean", "", "", []).


%% Criteria Database
has(social_anxiety_disorder) :- question_answer(f41, yes).

has(anxiety_disorder) :- has(general_anxiety_disorder).
has(anxiety_disorder) :- has(social_anxiety_disorder).

diagnosis(Result, successful) :- has(Result).
diagnosis(Result, out_of_capability) :- out_of_capability(Result).





%%% Init
:- init_current_indexs([f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f1_s1, f1_s2]).

debug_answers_yes([]).
debug_answers_yes([Question|List]) :-
    answer_question(Question, yes),
    debug_answers_yes(List).
debug_answers_no([]).
debug_answers_no([Question|List]) :-
    answer_question(Question, no),
    debug_answers_no(List).
