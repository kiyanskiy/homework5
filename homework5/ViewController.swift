/*
 Задание 3
 main поток: по умолчанию все задачи выполняются в главном потоке. главный поток является последовательным. все задачи, связанные с обновлением UI необходимо выполнять главном потоке
 global поток: глобальный поток является паралельным
 
 Задание 4
 при использовании Dispatch Queue просто указываем в какой очереди будет выполняться операция
 В Operation Queues есть возможность устанавливать зависимости между отдельными операциями, отменять поставленные в очередь операции
 Run loops это цикл который обрабатывает входящие события. В случае если событий нет то он переводит поток в спящий режим
 
 */

import UIKit

//задача d
protocol Task{
    func run()
}

class Task1: Task{
    func run(){
        let number = 10000
        var simple = true
        let start = DispatchTime.now()
        
        for i in 1...number{
            for j in 1...i{
                if j != 1 && j != i{
                    if i % j == 0{
                        simple = false
                    }
                }
            }
            if simple{
                print(i)
            }
            simple = true
        }
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        print(timeInterval)
        
    }
}

class MyQueue{
    var isActive = false
    var queue: [Task] = []
    func newTask(_ task: Task){
        if isActive{
            queue.append(task)
        }else{
            isActive = true
            runTask(task)
        }
        
    }
    
    func runTask(_ task: Task){
        DispatchQueue.global(qos: .utility).async { [weak self] in
            task.run()
            if let self = self{
                if self.queue.count > 0{
                    let newTask = self.queue[0]
                    self.queue.remove(at: 0)
                    self.runTask(newTask)
                }else{
                    self.isActive = false
                }
            }
           
        }
    }
    
}


class ViewController: UIViewController {
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    let imageURL = "https://st.depositphotos.com/1012291/1497/i/600/depositphotos_14976085-stock-photo-grass-landscape.jpg"
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let myQueue = MyQueue()
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView.frame = CGRect(x: 0, y: 0, width: 240, height: 120)
        blurView.layer.masksToBounds = true
    }
    //Задание а
    @IBAction func showPictureA(_ sender: Any) {
        let url = URL(string: imageURL)!
        for subUIView in firstImageView.subviews{
            subUIView.removeFromSuperview()
        }
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let data = (try? Data(contentsOf: url))!
            let image = UIImage(data: data)
            DispatchQueue.main.async { [weak self] in
                self?.firstImageView.image = image
            }

        }
    }
    //Задание b
    @IBAction func showPictureB(_ sender: Any) {
        let url = URL(string: imageURL)!
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let data = (try? Data(contentsOf: url))!
            let image = UIImage(data: data)
            DispatchQueue.main.async { [weak self] in
                self?.firstImageView.image = image
                self?.firstImageView.addSubview(self!.blurView)
            }
        }
        
}
    
    //Задание с
    @IBAction func calculate(_ sender: Any) {
        let number = Int(numberTextField.text ?? "") ?? 0
        var simple = true
        DispatchQueue.global(qos: .utility).async {
            let start = DispatchTime.now()
                
            for i in 1...number{
                for j in 1...i{
                    if j != 1 && j != i{
                        if i % j == 0{
                            simple = false
                        }
                    }
                }
                if simple{
                    print(i)
                }
                simple = true
            }	   
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            print(timeInterval)
        }
        
        
    }
    //Задание d
    @IBAction func addNewTask(_ sender: Any) {
        let task = Task1()
        myQueue.newTask(task)
        
    }
}

