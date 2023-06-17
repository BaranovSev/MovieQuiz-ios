import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - @IBOutlets
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - @IBActions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let currentQuestionAnswer = currentQuestion.correctAnswer
        let userAnswer = false
        showAnswerResult(isCorrect: currentQuestionAnswer == userAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let currentQuestionAnswer = currentQuestion.correctAnswer
        let userAnswer = true
        showAnswerResult(isCorrect: currentQuestionAnswer == userAnswer)
    }
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let statisticService = StatisticServiceImplementation()

//    private var allGamesResults: [GameResult] = []
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFonts()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        //        print(NSHomeDirectory()) узнаем путь к домашней дирректории устройства
        
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "top250MoviesIMDB.json"
        documentsURL.appendPathComponent(fileName)
        let jsonString = try? String(contentsOf: documentsURL)
        //        print(jsonString)
        guard let jsonString = jsonString else {
            return
        }
        
        guard let data = jsonString.data(using: .utf8) else {
            return
        }
        
        do {
            let top = try JSONDecoder().decode(Top.self, from: data)
            print(top)
        } catch {
            print("Failed to parse: \(error.localizedDescription)")
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private functions
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        buttonsToggle()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            self.buttonsToggle()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
//            allGamesResults.append(GameResult(correctAnswers, questionsAmount))
//            let greatestResult = allGamesResults.max{ a, b in a.correctAnswers < b.correctAnswers }
//            let summOfResults = Double(allGamesResults.compactMap{$0.correctAnswers}.reduce(0, +))
//            let sumOfQuestions = Double(allGamesResults.compactMap{$0.questionsTotal}.reduce(0, +))
//            let percentage = summOfResults * 100.0 / sumOfQuestions
//            let formatedPercentage = NSString(format: "%.2f", percentage)
//            guard let greatestResult = greatestResult else {
//                return
//            }
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(statisticService.totalAccuracy)%
            """
            currentQuestionIndex = 0
            correctAnswers = 0
            guard let questionFactory = questionFactory else {
                return
            }
            
            let alertModel = AlertModel(
                message: text,
                completion: questionFactory.requestNextQuestion()
            )
            AlertPresenter(onViewController: self).showAlert(alert: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
//    private func getMovie(from jsonString: String) -> Movie? {
//        var movie: Movie? = nil
//        do {
//            guard let data = jsonString.data(using: .utf8) else {
//                return nil
//            }
//            
//            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//
//            guard let json = json,
//                  let id = json["id"] as? String,
//                  let title = json["title"] as? String,
//                  let year = json["year"] as? String,
//                  let image = json["image"] as? String,
//                  let releaseDate = json["releaseDate"] as? String,
//                  let runtimeMins = json["runtimeMins"] as? String,
//                  let directors = json["directors"] as? String,
//                  let actorList = json["actorList"] as? [Any] else {
//                return nil
//            }
//
//            var actors: [Actor] = []
//
//            for actor in actorList {
//                guard let actor = actor as? [String: Any],
//                      let id = actor["id"] as? String,
//                      let image = actor["image"] as? String,
//                      let name = actor["name"] as? String,
//                      let asCharacter = actor["asCharacter"] as? String else {
//                    return nil
//                }
//                
//                let mainActor = Actor(id: id,
//                                      image: image,
//                                      name: name,
//                                      asCharacter: asCharacter)
//                actors.append(mainActor)
//            }
//            
//            movie = Movie(id: id,
//                          title: title,
//                          year: year,
//                          image: image,
//                          releaseDate: releaseDate,
//                          runtimeMins: runtimeMins,
//                          directors: directors,
//                          actorList: actors)
//        } catch {
//            print("Failed to parse: \(jsonString)")
//        }
//
//        return movie
//    }
    
    // MARK: - Helpers
    //move both func to the Helpers folder in future
    //troubleshooting with custom fonts
    private func setUpFonts(){
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
    }
    
    private func buttonsToggle(){
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
}
 

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
