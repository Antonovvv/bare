//
//  QtSheetWidget.cpp
//  Qt Widget for Sheet Integration
//
//  Created on 2024
//

#include "QtSheetWidget.h"
#include <QApplication>
#include <QStyle>

QtSheetWidget::QtSheetWidget(QWidget *parent)
    : QWidget(parent)
    , m_mainLayout(nullptr)
    , m_titleLabel(nullptr)
    , m_inputField(nullptr)
    , m_textArea(nullptr)
    , m_buttonLayout(nullptr)
    , m_okButton(nullptr)
    , m_cancelButton(nullptr)
{
    setupUI();
    setupConnections();
}

QtSheetWidget::~QtSheetWidget()
{
    // Qt会自动清理子对象
}

void QtSheetWidget::setupUI()
{
    // 主布局
    m_mainLayout = new QVBoxLayout(this);
    m_mainLayout->setContentsMargins(20, 20, 20, 20);
    m_mainLayout->setSpacing(15);

    // 标题
    m_titleLabel = new QLabel("Qt Sheet Dialog", this);
    m_titleLabel->setStyleSheet("QLabel { font-size: 16px; font-weight: bold; color: #333; }");
    m_titleLabel->setAlignment(Qt::AlignCenter);
    m_mainLayout->addWidget(m_titleLabel);

    // 输入框
    m_inputField = new QLineEdit(this);
    m_inputField->setPlaceholderText("Enter your input here...");
    m_inputField->setStyleSheet("QLineEdit { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }");
    m_mainLayout->addWidget(m_inputField);

    // 文本区域
    m_textArea = new QTextEdit(this);
    m_textArea->setPlaceholderText("Enter additional text here...");
    m_textArea->setMaximumHeight(120);
    m_textArea->setStyleSheet("QTextEdit { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }");
    m_mainLayout->addWidget(m_textArea);

    // 按钮布局
    m_buttonLayout = new QHBoxLayout();
    m_buttonLayout->addStretch(); // 左对齐

    // 确定按钮
    m_okButton = new QPushButton("OK", this);
    m_okButton->setDefault(true);
    m_okButton->setMinimumWidth(80);
    m_okButton->setStyleSheet(
        "QPushButton { "
        "    background-color: #007AFF; "
        "    color: white; "
        "    border: none; "
        "    padding: 8px 16px; "
        "    border-radius: 4px; "
        "    font-weight: bold; "
        "} "
        "QPushButton:hover { "
        "    background-color: #0056CC; "
        "} "
        "QPushButton:pressed { "
        "    background-color: #004499; "
        "}"
    );

    // 取消按钮
    m_cancelButton = new QPushButton("Cancel", this);
    m_cancelButton->setMinimumWidth(80);
    m_cancelButton->setStyleSheet(
        "QPushButton { "
        "    background-color: #6C757D; "
        "    color: white; "
        "    border: none; "
        "    padding: 8px 16px; "
        "    border-radius: 4px; "
        "    font-weight: bold; "
        "} "
        "QPushButton:hover { "
        "    background-color: #5A6268; "
        "} "
        "QPushButton:pressed { "
        "    background-color: #495057; "
        "}"
    );

    m_buttonLayout->addWidget(m_okButton);
    m_buttonLayout->addWidget(m_cancelButton);
    m_mainLayout->addLayout(m_buttonLayout);

    // 设置窗口属性
    setMinimumSize(400, 300);
    setMaximumSize(600, 500);
    resize(450, 350);
}

void QtSheetWidget::setupConnections()
{
    // 按钮信号连接
    connect(m_okButton, &QPushButton::clicked, this, &QtSheetWidget::onOkButtonClicked);
    connect(m_cancelButton, &QPushButton::clicked, this, &QtSheetWidget::onCancelButtonClicked);

    // 文本变化信号
    connect(m_inputField, &QLineEdit::textChanged, this, &QtSheetWidget::onTextChanged);
    connect(m_textArea, &QTextEdit::textChanged, this, &QtSheetWidget::onTextChanged);

    // 键盘快捷键
    m_okButton->setShortcut(QKeySequence(Qt::Key_Return));
    m_cancelButton->setShortcut(QKeySequence(Qt::Key_Escape));
}

QString QtSheetWidget::getUserInput() const
{
    return m_inputField->text();
}

void QtSheetWidget::setUserInput(const QString &text)
{
    m_inputField->setText(text);
}

void QtSheetWidget::resetForm()
{
    m_inputField->clear();
    m_textArea->clear();
}

bool QtSheetWidget::validateInput()
{
    QString input = m_inputField->text().trimmed();
    if (input.isEmpty()) {
        QMessageBox::warning(this, "Validation Error", "Please enter some text in the input field.");
        m_inputField->setFocus();
        return false;
    }
    return true;
}

void QtSheetWidget::onOkButtonClicked()
{
    if (validateInput()) {
        emit okClicked();
    }
}

void QtSheetWidget::onCancelButtonClicked()
{
    emit cancelClicked();
}

void QtSheetWidget::onTextChanged()
{
    emit dataChanged(m_inputField->text());
}