//
//  QtSheetWidget.h
//  Qt Widget for Sheet Integration
//
//  Created on 2024
//

#ifndef QTSHEETWIDGET_H
#define QTSHEETWIDGET_H

#include <QWidget>
#include <QPushButton>
#include <QVBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QTextEdit>
#include <QHBoxLayout>
#include <QMessageBox>

class QtSheetWidget : public QWidget
{
    Q_OBJECT

public:
    explicit QtSheetWidget(QWidget *parent = nullptr);
    ~QtSheetWidget();

    // 获取用户输入的数据
    QString getUserInput() const;
    void setUserInput(const QString &text);

signals:
    // 确定按钮信号
    void okClicked();
    // 取消按钮信号
    void cancelClicked();
    // 数据变化信号
    void dataChanged(const QString &data);

public slots:
    // 重置表单
    void resetForm();
    // 验证输入
    bool validateInput();

private slots:
    void onOkButtonClicked();
    void onCancelButtonClicked();
    void onTextChanged();

private:
    void setupUI();
    void setupConnections();

    // UI组件
    QVBoxLayout *m_mainLayout;
    QLabel *m_titleLabel;
    QLineEdit *m_inputField;
    QTextEdit *m_textArea;
    QHBoxLayout *m_buttonLayout;
    QPushButton *m_okButton;
    QPushButton *m_cancelButton;
};

#endif // QTSHEETWIDGET_H