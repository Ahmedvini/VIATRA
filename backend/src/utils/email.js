import config from '../config/index.js';
import logger from '../config/logger.js';

// Initialize SendGrid
sgMail.setApiKey(config.integrations.sendgrid.apiKey);

/**
 * Send email verification code
 * @param {string} email - Recipient email
 * @param {string} firstName - Recipient first name
 * @param {string} verificationCode - 6-digit verification code
 * @param {string} language - Preferred language (en/ar)
 * @returns {Promise<boolean>} - Success status
 */
export const sendVerificationEmail = async (email, firstName, verificationCode, language = 'en') => {
  try {
    const isArabic = language === 'ar';
    
    const subject = isArabic ? 'تأكيد البريد الإلكتروني - منصة فياترا الصحية' : 'Email Verification - Viatra Health';
    
    const htmlContent = isArabic ? `
      <!DOCTYPE html>
      <html dir="rtl" lang="ar">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>تأكيد البريد الإلكتروني</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f5f7fa; }
          .container { max-width: 600px; margin: 0 auto; background-color: white; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 40px; text-align: center; }
          .content { padding: 40px; }
          .verification-code { background-color: #f8f9ff; border: 2px dashed #667eea; padding: 20px; text-align: center; margin: 30px 0; border-radius: 8px; }
          .code { font-size: 32px; font-weight: bold; color: #667eea; letter-spacing: 4px; }
          .footer { background-color: #f8f9ff; padding: 20px 40px; text-align: center; color: #666; font-size: 14px; }
          .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 25px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>مرحباً ${firstName}!</h1>
            <p>شكراً لانضمامك إلى منصة فياترا الصحية</p>
          </div>
          <div class="content">
            <h2>تأكيد البريد الإلكتروني</h2>
            <p>لإكمال تسجيلك، يرجى استخدام رمز التأكيد التالي:</p>
            
            <div class="verification-code">
              <div class="code">${verificationCode}</div>
              <p>هذا الرمز صالح لمدة 24 ساعة</p>
            </div>
            
            <p>إذا لم تقم بإنشاء حساب، يرجى تجاهل هذا البريد الإلكتروني.</p>
          </div>
          <div class="footer">
            <p>منصة فياترا الصحية - رعاية صحية متقدمة</p>
            <p>هذا بريد إلكتروني تلقائي، يرجى عدم الرد عليه</p>
          </div>
        </div>
      </body>
      </html>
    ` : `
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Email Verification</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f5f7fa; }
          .container { max-width: 600px; margin: 0 auto; background-color: white; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 40px; text-align: center; }
          .content { padding: 40px; }
          .verification-code { background-color: #f8f9ff; border: 2px dashed #667eea; padding: 20px; text-align: center; margin: 30px 0; border-radius: 8px; }
          .code { font-size: 32px; font-weight: bold; color: #667eea; letter-spacing: 4px; }
          .footer { background-color: #f8f9ff; padding: 20px 40px; text-align: center; color: #666; font-size: 14px; }
          .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 25px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Welcome ${firstName}!</h1>
            <p>Thank you for joining Viatra Health Platform</p>
          </div>
          <div class="content">
            <h2>Email Verification</h2>
            <p>To complete your registration, please use the following verification code:</p>
            
            <div class="verification-code">
              <div class="code">${verificationCode}</div>
              <p>This code is valid for 24 hours</p>
            </div>
            
            <p>If you didn't create an account, please ignore this email.</p>
          </div>
          <div class="footer">
            <p>Viatra Health Platform - Advanced Healthcare Solutions</p>
            <p>This is an automated email, please do not reply</p>
          </div>
        </div>
      </body>
      </html>
    `;
    
    const msg = {
      to: email,
      from: {
        email: config.email.from,
        name: config.email.fromName
      },
      replyTo: config.email.replyTo,
      subject: subject,
      html: htmlContent
    };
    
    await sgMail.send(msg);
    
    logger.info('Verification email sent successfully', {
      email: email,
      language: language
    });
    
    return true;
  } catch (error) {
    logger.error('Error sending verification email:', error);
    return false;
  }
};

/**
 * Send password reset email
 * @param {string} email - Recipient email
 * @param {string} firstName - Recipient first name
 * @param {string} resetToken - Secure reset token
 * @param {string} language - Preferred language (en/ar)
 * @returns {Promise<boolean>} - Success status
 */
export const sendPasswordResetEmail = async (email, firstName, resetToken, language = 'en') => {
  try {
    const isArabic = language === 'ar';
    const resetUrl = `${config.frontend.url}/reset-password?token=${resetToken}`;
    
    const subject = isArabic ? 'إعادة تعيين كلمة المرور - منصة فياترا الصحية' : 'Password Reset - Viatra Health';
    
    const htmlContent = isArabic ? `
      <!DOCTYPE html>
      <html dir="rtl" lang="ar">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>إعادة تعيين كلمة المرور</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f5f7fa; }
          .container { max-width: 600px; margin: 0 auto; background-color: white; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 40px; text-align: center; }
          .content { padding: 40px; }
          .reset-button { text-align: center; margin: 30px 0; }
          .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 40px; text-decoration: none; border-radius: 25px; font-weight: bold; }
          .footer { background-color: #f8f9ff; padding: 20px 40px; text-align: center; color: #666; font-size: 14px; }
          .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>مرحباً ${firstName}</h1>
            <p>طلب إعادة تعيين كلمة المرور</p>
          </div>
          <div class="content">
            <h2>إعادة تعيين كلمة المرور</h2>
            <p>تلقينا طلباً لإعادة تعيين كلمة المرور لحسابك. انقر على الزر أدناه لإنشاء كلمة مرور جديدة:</p>
            
            <div class="reset-button">
              <a href="${resetUrl}" class="button">إعادة تعيين كلمة المرور</a>
            </div>
            
            <div class="warning">
              <strong>تنبيه:</strong> هذا الرابط صالح لمدة ساعة واحدة فقط لأسباب أمنية.
            </div>
            
            <p>إذا لم تطلب إعادة تعيين كلمة المرور، يرجى تجاهل هذا البريد الإلكتروني. حسابك آمن.</p>
            
            <p>إذا لم يعمل الزر، يمكنك نسخ الرابط التالي ولصقه في متصفحك:</p>
            <p style="word-break: break-all; color: #667eea;">${resetUrl}</p>
          </div>
          <div class="footer">
            <p>منصة فياترا الصحية - رعاية صحية متقدمة</p>
            <p>هذا بريد إلكتروني تلقائي، يرجى عدم الرد عليه</p>
          </div>
        </div>
      </body>
      </html>
    ` : `
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Password Reset</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f5f7fa; }
          .container { max-width: 600px; margin: 0 auto; background-color: white; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 40px; text-align: center; }
          .content { padding: 40px; }
          .reset-button { text-align: center; margin: 30px 0; }
          .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 40px; text-decoration: none; border-radius: 25px; font-weight: bold; }
          .footer { background-color: #f8f9ff; padding: 20px 40px; text-align: center; color: #666; font-size: 14px; }
          .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Hello ${firstName}</h1>
            <p>Password Reset Request</p>
          </div>
          <div class="content">
            <h2>Reset Your Password</h2>
            <p>We received a request to reset your password. Click the button below to create a new password:</p>
            
            <div class="reset-button">
              <a href="${resetUrl}" class="button">Reset Password</a>
            </div>
            
            <div class="warning">
              <strong>Important:</strong> This link is valid for only 1 hour for security reasons.
            </div>
            
            <p>If you didn't request a password reset, please ignore this email. Your account is secure.</p>
            
            <p>If the button doesn't work, you can copy and paste the following link into your browser:</p>
            <p style="word-break: break-all; color: #667eea;">${resetUrl}</p>
          </div>
          <div class="footer">
            <p>Viatra Health Platform - Advanced Healthcare Solutions</p>
            <p>This is an automated email, please do not reply</p>
          </div>
        </div>
      </body>
      </html>
    `;
    
    const msg = {
      to: email,
      from: {
        email: config.email.from,
        name: config.email.fromName
      },
      replyTo: config.email.replyTo,
      subject: subject,
      html: htmlContent
    };
    
    await sgMail.send(msg);
    
    logger.info('Password reset email sent successfully', {
      email: email,
      language: language
    });
    
    return true;
  } catch (error) {
    logger.error('Error sending password reset email:', error);
    return false;
  }
};

/**
 * Send welcome email
 * @param {string} email - Recipient email
 * @param {string} firstName - Recipient first name
 * @param {string} role - User role (patient/doctor)
 * @param {string} language - Preferred language (en/ar)
 * @returns {Promise<boolean>} - Success status
 */
export const sendWelcomeEmail = async (email, firstName, role, language = 'en') => {
  try {
    const isArabic = language === 'ar';
    const isDoctor = role === 'doctor';
    
    const subject = isArabic ? 
      `مرحباً بك في منصة فياترا الصحية - ${isDoctor ? 'حساب طبيب' : 'حساب مريض'}` : 
      `Welcome to Viatra Health - ${isDoctor ? 'Doctor Account' : 'Patient Account'}`;
    
    const htmlContent = isArabic ? `
      <!DOCTYPE html>
      <html dir="rtl" lang="ar">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>مرحباً بك في فياترا</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f5f7fa; }
          .container { max-width: 600px; margin: 0 auto; background-color: white; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; text-align: center; }
          .content { padding: 40px; }
          .features { background-color: #f8f9ff; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .feature-item { margin: 10px 0; padding: 10px 0; border-bottom: 1px solid #e0e0e0; }
          .footer { background-color: #f8f9ff; padding: 20px 40px; text-align: center; color: #666; font-size: 14px; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>مرحباً ${firstName}! 🎉</h1>
            <p>أهلاً بك في منصة فياترا الصحية</p>
          </div>
          <div class="content">
            <h2>تم إنشاء حسابك بنجاح</h2>
            <p>نحن سعداء لانضمامك إلى عائلة فياترا الصحية كـ${isDoctor ? 'طبيب معتمد' : 'مريض'}.</p>
            
            <div class="features">
              <h3>ما يمكنك فعله الآن:</h3>
              ${isDoctor ? `
                <div class="feature-item">📋 إكمال ملفك الطبي المهني</div>
                <div class="feature-item">📄 رفع المستندات المطلوبة للتحقق</div>
                <div class="feature-item">📅 إدارة مواعيدك وجدولك</div>
                <div class="feature-item">💬 التواصل مع المرضى بأمان</div>
              ` : `
                <div class="feature-item">📝 إكمال ملفك الصحي</div>
                <div class="feature-item">🔍 البحث عن الأطباء المختصين</div>
                <div class="feature-item">📅 حجز المواعيد الطبية</div>
                <div class="feature-item">💊 متابعة تاريخك الطبي</div>
              `}
            </div>
            
            <p>فريق دعم العملاء متاح على مدار الساعة لمساعدتك.</p>
          </div>
          <div class="footer">
            <p>منصة فياترا الصحية - رعاية صحية متقدمة</p>
            <p>للدعم الفني: support@viatra.health</p>
          </div>
        </div>
      </body>
      </html>
    ` : `
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome to Viatra</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f5f7fa; }
          .container { max-width: 600px; margin: 0 auto; background-color: white; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; text-align: center; }
          .content { padding: 40px; }
          .features { background-color: #f8f9ff; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .feature-item { margin: 10px 0; padding: 10px 0; border-bottom: 1px solid #e0e0e0; }
          .footer { background-color: #f8f9ff; padding: 20px 40px; text-align: center; color: #666; font-size: 14px; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Welcome ${firstName}! 🎉</h1>
            <p>Thank you for joining Viatra Health Platform</p>
          </div>
          <div class="content">
            <h2>Your account has been created successfully</h2>
            <p>We're excited to have you join the Viatra Health family as a ${isDoctor ? 'certified healthcare provider' : 'valued patient'}.</p>
            
            <div class="features">
              <h3>What you can do now:</h3>
              ${isDoctor ? `
                <div class="feature-item">📋 Complete your professional medical profile</div>
                <div class="feature-item">📄 Upload required verification documents</div>
                <div class="feature-item">📅 Manage your appointments and schedule</div>
                <div class="feature-item">💬 Communicate securely with patients</div>
              ` : `
                <div class="feature-item">📝 Complete your health profile</div>
                <div class="feature-item">🔍 Search for specialized doctors</div>
                <div class="feature-item">📅 Book medical appointments</div>
                <div class="feature-item">💊 Track your medical history</div>
              `}
            </div>
            
            <p>Our support team is available 24/7 to assist you with any questions.</p>
          </div>
          <div class="footer">
            <p>Viatra Health Platform - Advanced Healthcare Solutions</p>
            <p>For support: support@viatra.health</p>
          </div>
        </div>
      </body>
      </html>
    `;
    
    const msg = {
      to: email,
      from: {
        email: config.email.from,
        name: config.email.fromName
      },
      replyTo: config.email.replyTo,
      subject: subject,
      html: htmlContent
    };
    
    await sgMail.send(msg);
    
    logger.info('Welcome email sent successfully', {
      email: email,
      role: role,
      language: language
    });
    
    return true;
  } catch (error) {
    logger.error('Error sending welcome email:', error);
    return false;
  }
};
