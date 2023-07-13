import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        setUpFonts()
        showLoadingIndicator()
    }
    
    // MARK: - Private functions
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Поробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.loadDataAfterError()
            self.presenter.restartGame()
        }
        
        AlertPresenter(onViewController: self).showAlert(alert: model)
    }

    // MARK: - Helpers
    private func setUpFonts(){
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
    }
    
    func buttonsToggle(){
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: - @IBActions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}
